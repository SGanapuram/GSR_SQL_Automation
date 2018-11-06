SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_daily_paper_position_report]
(
   @pl_asof_date		datetime = null,
   @port_nums			  varchar(max) = null,
   @dept_code			  varchar(50) = null,
   @desk_code			  varchar(50) = null,
   @debugon			    bit = 0 
)
as
set nocount on
declare @rows_affected		int,  
        @smsg			        varchar(255),  
        @status		        int,  
        @oid			        numeric(18, 0),  
        @stepid			      smallint,  
        @session_started	varchar(30),  
        @session_ended		varchar(30),
        @my_pl_asof_date	datetime,
        @my_dept_code		  varchar(50),
        @my_desk_code		  varchar(50),
        @my_port_nums		  varchar(8000)

   select @my_pl_asof_date = @pl_asof_date,
          @my_dept_code = @dept_code,
          @my_desk_code = @desk_code,
          @my_port_nums	= @port_nums

   create table #output
   (
	    real_port_num		      int,
	    trade_num		          int,
	    order_num		          datetime,
      item_num		          char(8),
      dist_type		          varchar(20),
	    qty			              decimal(20, 8),
	    qty_uom_code_conv_to	varchar(20),
	    sec_conversion_factor	decimal(20, 8),
	    sec_qty_uom_code	    varchar(20),
	    cmdty_code		        varchar(15),
	    item_type		          varchar(15),
	    dept_code		          varchar(15),
	    row_type		          varchar(15)
   )

   -- Get All Non Inventory Positions
   insert into #output
	    (real_port_num,
	     trade_num,
	     order_num,
       item_num,
       dist_type,
	     qty,
	     qty_uom_code_conv_to,
	     sec_conversion_factor,
	     sec_qty_uom_code,
	     cmdty_code,
	     item_type,
	     dept_code,
	     row_type)
   select	
      tid.real_port_num,
		  tid.trade_num,
		  tid.order_num, 
		  tid.item_num, 
		  tid.dist_type,
		  (tid.dist_qty - tid.alloc_qty) * tid.qty_uom_conv_rate, -- Apply the uom conversion here as explaine below.
		  tid.qty_uom_code_conv_to,
		  tid.sec_conversion_factor,
		  tid.sec_qty_uom_code,
		  p.cmdty_code,
		  case when ti.item_type in ('W','T','S') 
		          then 'PHYSICAL' 
		       else 'PAPER' 
		  end 'item_type',
		  d1.dept_code,
		  'inventory'
   from dbo.trade t
           join dbo.icts_user iu 
              on iu.user_init = t.trader_init
           join dbo.desk d 
              on d.desk_code = iu.desk_code
           join dbo.department d1 
              on d.dept_code = d1.dept_code and 
                 d1.dept_code in ('CRUDE', 'PRODUCTS')
           join dbo.trade_order tor 
              on tor.trade_num = t.trade_num
           join dbo.trade_item ti 
              on ti.trade_num = tor.trade_num and 
                 ti.order_num = tor.order_num
           join dbo.trade_item_dist tid 
              on tid.trade_num = ti.trade_num and 
                 tid.order_num = ti.order_num and 
                 tid.item_num = ti.item_num 
           join dbo.position p 
              on p.pos_num = tid.pos_num
   where user_status = 'A' and
         exists (select 1 
                 from dbo.pl_history plh 
                 where plh.real_port_num = tid.real_port_num and
										   plh.pl_secondary_owner_key1 = tid.trade_num and
										   plh.pl_secondary_owner_key2 = tid.order_num and
										   plh.pl_secondary_owner_key3 = tid.item_num and
										   pl_asof_date = (select max(pl_asof_date) 
														           from dbo.portfolio_profit_loss 
														           where pl_asof_date <= @my_pl_asof_date))	and 
		     ((item_type in ('W','F','X', 'E') and dist_type = 'D') or 
	        (item_type = 'C' and dist_type = 'U') or
	        (item_type in ('O') and dist_type = 'D' and tid.is_equiv_ind = 'Y')) and
			   1 = (case when @my_port_nums is null then 1   
                   when ti.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1 
              end) and 
	       d1.dept_code in (select * from dbo.fnToSplit(@my_dept_code, ','))
   order by d1.dept_code, ti.item_type, ti.trade_num, ti.order_num, ti.item_num


   -- Get All Inventory Positions
   insert into #output
	    (real_port_num,
	     trade_num,
	     order_num,
       item_num,
       dist_type,
	     qty,
	     qty_uom_code_conv_to,
	     sec_conversion_factor,
	     sec_qty_uom_code,
	     cmdty_code,
	     item_type,
	     dept_code,row_type)
   select	
      ti.real_port_num,
		  ti.trade_num,
		  ti.order_num, 
		  ti.item_num, 
		  null 'dist_type',
		  i.inv_open_prd_proj_qty + i.inv_open_prd_actual_qty + i.inv_adj_qty + i.inv_cnfrmd_qty, --Primary Quantity
		  i.inv_qty_uom_code,
		  i.inv_open_prd_proj_sec_qty + i.inv_open_prd_actual_sec_qty + i.inv_adj_qty + i.inv_cnfrmd_sec_qty, -- Secondary Quantity
		  i.inv_sec_qty_uom_code,
		  i.cmdty_code,
		  case when ti.item_type in ('W','T','S') then 'PHYSICAL' 
		       else 'PAPER' 
		  end 'item_type',
		  d1.dept_code,'noninventory'
   from dbo.trade t
           join dbo.icts_user iu 
              on iu.user_init=t.trader_init
           join dbo.desk d 
              on d.desk_code = iu.desk_code
           join dbo.department d1 
              on d.dept_code = d1.dept_code
           join dbo.trade_order tor 
              on tor.trade_num = t.trade_num
           join dbo.trade_item ti 
              on ti.trade_num = tor.trade_num and 
                 ti.order_num = tor.order_num
           join dbo.inventory i 
              on ti.trade_num = i.trade_num and 
                 ti.order_num = i.order_num and 
                 ti.item_num = i.sale_item_num
   where user_status = 'A' and
         exists (select 1 
                 from dbo.inventory_history ih 
                 where ih.real_port_num = ti.real_port_num and
						           ih.inv_num = i.inv_num and
                       asof_date = @my_pl_asof_date) and
        (item_type in ('T', 'S')) and 
			  1 = (case when @my_port_nums is null then 1   
                  when ti.real_port_num in (Select * from dbo.udf_split(@my_port_nums,',')) then 1 
             end) and 
        d1.dept_code in (select * 
                         from dbo.fnToSplit(@my_dept_code, ','))
   order by d1.dept_code, ti.item_type, ti.trade_num, ti.order_num, ti.item_num


   --Return the output
   --sec_qty_uom_code,cmdty_code,item_type,dept_code from #output

   if (@my_desk_code is null)
   begin
	    select item_type,
	           sum(case dept_code when 'CRUDE' then qty 
	                              else 0 
	               end) 'CRUDE',
	           sum(case dept_code when 'PRODUCTS' then qty 
	                              else 0 
	               end) 'PRODUCTS' 
	    from #output
      group by item_type
   end
   else
   begin
	    select item_type,
	           sum(case o.dept_code when 'CRUDE' then qty 
	                                else 0 
	               end) 'CRUDE',
	           sum(case o.dept_code when 'PRODUCTS' then qty 
	                                else 0 
	               end) 'PRODUCTS' 
	    from #output o 
	            join dbo.desk d 
	               on (d.dept_code = o.dept_code) 
	    where d.desk_code in (select * 
	                          from dbo.fnToSplit(@my_desk_code, ','))
	    group by item_type
   end

drop table #output

endofsp:  
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_daily_paper_position_report] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_daily_paper_position_report', NULL, NULL
GO
