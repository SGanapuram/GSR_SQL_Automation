SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_invtdtls_for_poshist]
(
   @asof_date    datetime,
   @debugon      bit = 0,
   @pos_num      int
)
as
set nocount on
declare @my_pos_num        int,
        @my_asof_date	     datetime,
        @rows_affected     int,
        @errcode           int,
	      @inv_num	         int

   select	@my_pos_num = @pos_num,
	        @my_asof_date = @asof_date,
	        @errcode = 0

   /* Verifying argument values */
   if @my_pos_num is null or
      @my_asof_date is null
   begin
      print 'You must provide a value for both @pos_num and @asof_date arguments!'
      goto reportusage
   end

   create table #pos_hist
   (
      pos_num     int not null,
      trans_id    int not null
   )

   create table #inv
   (
      is_audit		          char(1) not null,
      inv_num		            int not null,
      prev_inv_num		      int null,
      next_inv_num		      int null,
      open_close_ind	      char(1),
      prev_open_close_ind 	char(1) null,
      inv_open_qty		      numeric(20, 8) null,
      inv_curr_qty		      numeric(20, 8) null,
      inv_qty_uom_code	    char(4) not null,
      trans_id		          int not null
   )

   create table #ai
   (
      is_audit		        char(1) not null,
      alloc_num    	      int not null,
      alloc_item_num 	    int not null,
      inv_num		          int not null,
      trade_num    	      int not null,
      order_num	 	        int not null,
      item_num		        int not null,
      alloc_item_type	    char(1) not null,
      fully_actualized 	  char(1) not null,
      actual_gross_qty	  numeric(20, 8) null,
      nomin_qty_max	      numeric(20, 8) null,
      sch_qty_periodicity	char(1) not null,
      qty			            numeric(20,8) null,
      type_str		        varchar(20) null,
      ai_str		          varchar(30) null,
      prd_start_date	    datetime null,
      prd_end_date		    datetime null,
      trans_id		        int not null
   )

   create table #results
   (
      oid		        int IDENTITY primary key,
      type		      varchar(20) not null,
      quantity    	numeric(20, 8) not null,
      uom_code 	    char(4) not null,
      inv_ai_str	  varchar(30) not null
   )

   /* get the position record and trans_id from 
      position_history table for given pos_num and asof_date
   */
   insert into #pos_hist
   select pos_num,
	        trans_id 
   from dbo.position_history
   where pos_num = @my_pos_num and
	       asof_date = @my_asof_date
   select @rows_affected = @@rowcount,
	        @errcode = @@error
   if @errcode > 0 or @rows_affected = 0
	    goto endofsp

   /* obtain the exact inventory records based on 
      the position number and trans_id
   */
   insert into #inv
   select 'Y',
	        inv.inv_num, 
	        inv.prev_inv_num,
	        inv.next_inv_num,
	        inv.open_close_ind,
	        NULL,
	        isnull(inv.inv_open_prd_proj_qty, 0) + isnull(inv.inv_open_prd_actual_qty, 0),
	        isnull(inv.inv_curr_proj_qty, 0) + isnull(inv.inv_curr_actual_qty, 0),
	        inv.inv_qty_uom_code,
	        #ph.trans_id
   from dbo.aud_inventory inv
           join #pos_hist #ph 
              on inv.pos_num = #ph.pos_num and 
	               inv.trans_id <= #ph.trans_id and 
	               inv.resp_trans_id > #ph.trans_id
   union
   select 'N',
	        inv.inv_num, 
	        inv.prev_inv_num,
	        inv.next_inv_num,
	        inv.open_close_ind,
	        NULL,
	        isnull(inv.inv_open_prd_proj_qty, 0) + isnull(inv.inv_open_prd_actual_qty, 0),
	        isnull(inv.inv_curr_proj_qty, 0) + isnull(inv.inv_curr_actual_qty, 0),
	        inv.inv_qty_uom_code,
	        #ph.trans_id
   from dbo.inventory inv
           join #pos_hist #ph 
              on inv.pos_num = #ph.pos_num and 
	               inv.trans_id <= #ph.trans_id 

   /*  get the open_close_ind for previous inventories */

   update #inv
   set prev_open_close_ind = prevInv.open_close_ind
   from #inv
           join (select inv.inv_num, 
		                    inv.open_close_ind,
		                    inv.trans_id
	               from dbo.aud_inventory inv
	                       join #inv 
	                          on inv.inv_num = #inv.prev_inv_num and 
		                           inv.trans_id <= #inv.trans_id and 
		                           inv.resp_trans_id > #inv.trans_id
	               union
	               select inv.inv_num, 
			                  inv.open_close_ind,
			                  inv.trans_id
	               from dbo.inventory inv
	                       join #inv 
	                          on inv.inv_num = #inv.prev_inv_num and 
		                           inv.trans_id <= #inv.trans_id) prevInv 
		          on #inv.prev_inv_num = prevInv.inv_num 

   /* get allocation items for the inventories */
   insert into #ai
     select 'Y',
	          alloc_num,
	          alloc_item_num,
	          ai.inv_num,
	          ai.trade_num,
	          ai.order_num,
	          ai.item_num,
	          alloc_item_type,
	          fully_actualized,
	          actual_gross_qty,
	          nomin_qty_max,
	          sch_qty_periodicity,
	          case fully_actualized 
		           when 'Y' then actual_gross_qty
		           else nomin_qty_max -- Need to apply [anAi getExtendedQty:qty] logic
	          end,
	          case alloc_item_type 
		           when 'P' then 'Adj(+)'
		           when 'M' then 'Adj(-)'
		           when 'I' then 'D (S)'
		           when 'N' then 'D (T)'
		           when 'C' then 'B (S)'
		           when 'T' then 'B (T)'
		           when 'B' then 'D (B)'
		           when 'S' then 'B (B)'
		           when 'E' then 'D (E)'
		           when 'F' then 'B (E)'
		           else ''
	          end,
	          case alloc_item_type 
		           when 'P' then cast(ai.inv_num as varchar)
		           when 'M' then cast(ai.inv_num as varchar)
		           else cast(ai.alloc_num as varchar) + '-' + 
		                cast(ai.alloc_item_num as varchar) + '-' + 
		                cast(ai.inv_num as varchar)
	          end,
	          NULL,
	          NULL,
	          #inv.trans_id
   from dbo.aud_allocation_item ai
           join #inv 
              on ai.inv_num = #inv.inv_num and 
	               ai.trans_id <= #inv.trans_id and 
	               ai.resp_trans_id > #inv.trans_id
   where ai.alloc_item_status != 'A'
   union
   select 'N',
	        alloc_num,
	        alloc_item_num,
	        ai.inv_num,
	        ai.trade_num,
	        ai.order_num,
	        ai.item_num,
	        alloc_item_type,
	        fully_actualized,
	        actual_gross_qty,
	        nomin_qty_max,
	        sch_qty_periodicity,
	        case fully_actualized 
		         when 'Y' then actual_gross_qty
		         else nomin_qty_max -- Need to apply [anAi getExtendedQty:qty] logic
	        end,
	        case alloc_item_type 
		           when 'P' then 'Adj(+)'
		           when 'M' then 'Adj(-)'
		           when 'I' then 'D (S)'
		           when 'N' then 'D (T)'
		           when 'C' then 'B (S)'
		           when 'T' then 'B (T)'
		           when 'B' then 'D (B)'
		           when 'S' then 'B (B)'
		           when 'E' then 'D (E)'
		           when 'F' then 'B (E)'
		           else ''
	        end,
	        case alloc_item_type 
		           when 'P' then cast(ai.inv_num as varchar)
		           when 'M' then cast(ai.inv_num as varchar)
		           else cast(ai.alloc_num as varchar) + '-' + 
		                cast(ai.alloc_item_num as varchar) + '-' + 
		                cast(ai.inv_num as varchar)
	        end,
	        NULL,
	        NULL,
	        #inv.trans_id
   from dbo.allocation_item ai
           join #inv 
              on ai.inv_num = #inv.inv_num and 
	               ai.trans_id <= #inv.trans_id 
   where ai.alloc_item_status != 'A'

   /* Update delivery period for storage trades for
      calculating extended quantity for montly and
      day periodicity.
   */
   update #ai
   set prd_start_date = storage_start_date,
       prd_end_date = storage_end_date
   from #ai 
           join (select tis.trade_num,
		                    tis.order_num,
		                    tis.item_num,
		                    storage_start_date,
		                    storage_end_date
	               from dbo.aud_trade_item_storage tis
	                       join #ai 
	                          on tis.trade_num = #ai.trade_num and
		                           tis.order_num = #ai.order_num and
		                           tis.item_num = #ai.item_num and
		                           tis.trans_id <= #ai.trans_id and 
		                           tis.resp_trans_id > #ai.trans_id
      	         where #ai.sch_qty_periodicity not in ('L', 'V') and
		                   #ai.fully_actualized <> 'Y'
                 union
	               select tis.trade_num,
		                    tis.order_num,
		                    tis.item_num,
		                    storage_start_date,
		                    storage_end_date
	               from dbo.trade_item_storage tis
	                       join #ai 
	                          on tis.trade_num = #ai.trade_num and
		                           tis.order_num = #ai.order_num and
		                           tis.item_num = #ai.item_num and
		                           tis.trans_id <= #ai.trans_id
      	         where #ai.sch_qty_periodicity not in ('L', 'V') and
		                   #ai.fully_actualized <> 'Y') tis 
           on tis.trade_num = #ai.trade_num and
              tis.order_num = #ai.order_num and
              tis.item_num = #ai.item_num 

   /* 
      Update delivery period for transportation trades for
      calculating extended quantity for montly and
      day periodicity.
   */
   update #ai
   set prd_start_date = load_date_from,
       prd_end_date = load_date_to
   from #ai
           join (select trans.trade_num,
		                    trans.order_num,
		                    trans.item_num,
		                    load_date_from,
		                    load_date_to
	               from #ai
	                       join aud_trade_item_transport trans 
	                          on trans.trade_num = #ai.trade_num and
		                           trans.order_num = #ai.order_num and
		                           trans.item_num = #ai.item_num and
		                           trans.trans_id <= #ai.trans_id and 
		                           trans.resp_trans_id > #ai.trans_id
      	         where #ai.sch_qty_periodicity not in ('L', 'V') and
		                   #ai.fully_actualized <> 'Y'
                 union
	               select trans.trade_num,
		                    trans.order_num,
		                    trans.item_num,
		                    load_date_from,
		                    load_date_to
	               from dbo.trade_item_transport trans
	                       join #ai 
	                          on trans.trade_num = #ai.trade_num and
                               trans.order_num = #ai.order_num and
		                           trans.item_num = #ai.item_num and
		                           trans.trans_id <= #ai.trans_id
      	         where #ai.sch_qty_periodicity not in ('L', 'V') and
		                   #ai.fully_actualized <> 'Y') trans 
		          on trans.trade_num = #ai.trade_num and
                 trans.order_num = #ai.order_num and
                 trans.item_num = #ai.item_num 

    /* There are only Life, Day and Month Peridicity used in ICTS now,
       So only handling these cases*/
	  update #ai
	  set qty = qty * (case sch_qty_periodicity 
			                  when 'D' then (datediff(dd, prd_start_date, prd_end_date) + 1) 
			                  when 'M' then (datediff(mm, prd_start_date, prd_end_date) + 1) 
		                 end)
	  where sch_qty_periodicity not in ('L', 'V') and
		      fully_actualized <> 'Y'

    /* loop thru inventories and build the output data.
       For given inventory the results should be in this order
         1. If previous inventory is rolled or closed then show the open qty.
         2. get all allocation items records for the inv
         3. If current inventory is rolled or closed then show closed qty
    */
	   select @inv_num = min(inv_num)  
	   from #inv   
      
	   while @inv_num is not null  
	   begin  
		    insert into #results (type, quantity, uom_code, inv_ai_str)
		      select 'Open',
			           inv_open_qty,  
			           inv_qty_uom_code,
			           cast(inv_num as varchar)+ ' (rolled from ' + cast(prev_inv_num as varchar) + ')'   
          from #inv  
          where inv_num = @inv_num and
	              prev_open_close_ind in ('C', 'R')
         
        insert into #results (type, quantity, uom_code, inv_ai_str)
          select type_str,
      	         qty,  
	               inv_qty_uom_code,
                 ai_str   
          from #inv
                  join #ai 
                     on #ai.inv_num = #inv.inv_num
          where #inv.inv_num = @inv_num
          order by alloc_num, alloc_item_num

          insert into #results (type, quantity, uom_code, inv_ai_str)
          select 'Closed',
      	         inv_curr_qty,  
	               inv_qty_uom_code,
			           cast(inv_num as varchar)+ ' (rolled to ' + cast(next_inv_num as varchar) + ')'   
          from #inv  
          where inv_num = @inv_num and
	              open_close_ind in ('C', 'R')

          select @inv_num = min(inv_num)  
          from #inv   
          where inv_num > @inv_num              
     end    
     select * 
     from #results
     order by oid
     goto endofsp

reportusage:
   print 'Usage: exec dbo.usp_get_invtdtls_for_poshist'
   print '                      @pos_num = ?,'
   print '                      @asof_date = ?,'
   print '                      [, @debugon = ?]'
   return 2

endofsp:
   drop table #pos_hist
   drop table #inv
   drop table #ai
   drop table #results
   if @errcode = 0
      return 0
   return 1
GO
GRANT EXECUTE ON  [dbo].[usp_get_invtdtls_for_poshist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_invtdtls_for_poshist', NULL, NULL
GO
