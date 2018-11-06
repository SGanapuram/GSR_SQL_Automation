SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[tabbed_pl_data]
(
   @pl_asof_date   datetime,
   @port_num_list  varchar(2000)
)
as
set nocount on
declare @rows_affected     int,  
        @smsg              varchar(255),  
        @status            int,  
        @oid               numeric(18, 0),  
        @stepid            smallint,  
        @session_started   varchar(30),  
        @session_ended     varchar(30),  
        @my_port_num_list  varchar(2000),  
        @my_pl_asof_date   datetime,
        @errcode           int,
        @qty_uom_code      char(4),
        @price_uom_code    char(4),
        @cmdty_code        char(8)

   create table #port_data
   (  
      real_port_num			int,
      pl_asof_date	    datetime,
      PRIMARY KEY (real_port_num, pl_asof_date)
   ) 
      
   create table #portnums
   (  
      port_num			int primary key
   ) 

   create table #prev_pl
   (  
      trade_num			    int,  
      order_num			    int,  
      item_num          int, 
      real_port_num     int,
      curr_pl_amt       numeric(20, 8) null,
      PRIMARY KEY (trade_num, order_num, item_num, real_port_num)
   )

   create table #pltypes
   (  
      pl_type		char(8)  primary key
   )

   create table #uomconv
   (
      oid                 numeric(18, 0) IDENTITY primary key,
      qty_uom_code        char(4) null, 
      price_uom_code      char(4) null,      
      cmdty_code          char(8) null,
      conv_rate           numeric(20, 8) 
   )

   create table #ti_data
   (  
      trade_num			        int not null,  
      order_num			        int not null,  
      item_num              int not null, 
      cmdty_full_name	     	char(40) null,
      counterparty		      varchar(510) null,
      booking_company		    varchar(510) null,
      trader_init	          char(8) null,  
      contract_date         datetime null, 
      inhouse_ind		        char(1) null,
      item_type			        char(1) null,
      p_s_ind			          char(1) null,
      formula_ind		        char(1) null,
      inhouse_real_port_num	int null,
      real_port_num		      int not null,
      avg_price			        numeric(20, 8) null,
      price_uom_code		    char(8) null,
      price_curr_code		    char(8) null,
      dist_qty             	numeric(20, 8) null,      
      qty_uom_code	       	char(8) null,
      extended_value		    numeric(20, 8) null,
      curr_pl_amt		        numeric(20, 8) null,   
      pl_amt			          numeric(20, 8) null,
      due_date			        datetime null,
      trading_prd_desc		  varchar(40) null,
      port_short_name		    varchar(25) null,
      bbl_qty			          numeric(20, 8) null,
      put_call_ind		      char(1) null,
      strike_price		      numeric(20, 8) null,
      premium_price		      numeric(20, 8) null,
      accum_start_date      datetime null,
      accum_end_date     	  datetime null,
      cmdty_code		        char(8) null,
      commkt_key		        int null,
      order_type_code 		  varchar(8) null,
      dist_type             char(1) null,
      PRIMARY KEY (trade_num, order_num, item_num, real_port_num)
   ) 
   
   create nonclustered index x0910_ti_data_idx1 on #ti_data(trade_num, order_num, item_num, item_type)
   create nonclustered index x0910_ti_data_idx2 on #ti_data(real_port_num, dist_type)
   create nonclustered index x0910_ti_data_idx3 on #ti_data(cmdty_code, qty_uom_code, price_uom_code)
   create nonclustered index x0910_ti_data_idx4 on #ti_data(trade_num, order_num, item_num, formula_ind)
   create nonclustered index x0910_ti_data_idx5 on #ti_data(real_port_num, trade_num, order_num, item_num)
   
   select @errcode = 0,
          @status = 0
   if @pl_asof_date is null
   begin
      select @smsg = '=> You must provide a valid date for the argument @pl_asof_date!'
      goto reportusage
   end
   if @port_num_list is null
   begin
      select @smsg = '=> You must provide a string consists of a number of port_num(s) for the argument @port_num_list!'
      goto reportusage
   end
   
   select @my_pl_asof_date = @pl_asof_date,  
          @my_port_num_list = @port_num_list

   insert into #pltypes (pl_type) values('I')
   insert into #pltypes (pl_type) values('W')
     
   insert into #portnums
      select distinct convert(int, data) from udf_split(@my_port_num_list, ',')
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
      goto endofsp
   if @rows_affected = 0
   begin
      print '=> The port_nums were NOT given!'
      goto endofsp      
   end
   
   insert into #port_data 
      (real_port_num, pl_asof_date)
    select port_num,
	         CONVERT(varchar, max(pl_asof_date), 101) 
    from dbo.portfolio_profit_loss pl
    where pl_asof_date < @my_pl_asof_date and
          exists (select 1
                  from #portnums p
                  where pl.port_num = p.port_num)                  
    group by port_num	
   select @rows_affected = @@rowcount,
          @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   /* if the previous day records are not there we 
      still have to proceed with other steps.
   */
      
   insert into #prev_pl 
       (trade_num, order_num, item_num, real_port_num, curr_pl_amt)
    select pl.pl_secondary_owner_key1,
	         pl.pl_secondary_owner_key2, 
	         pl.pl_secondary_owner_key3,
	         pl.real_port_num,
	         sum(pl.pl_amt)
    from (select plhist.pl_record_key,
		             plhist.pl_secondary_owner_key1,  
	               plhist.pl_secondary_owner_key2, 
	               plhist.pl_secondary_owner_key3,
	               plhist.real_port_num,
	               plhist.pl_amt
          from dbo.pl_history plhist 
                 join #port_data pd on 
	                  plhist.pl_asof_date = pd.pl_asof_date and
	                  plhist.real_port_num = pd.real_port_num	
          where exists (select 1
                        from #pltypes typ
                        where plhist.pl_type <> typ.pl_type) and	                
	              plhist.pl_cost_prin_addl_ind = 'P' and  
	              plhist.pl_secondary_owner_key1 <> 0
          union
          select plhist.pl_record_key,
                 plhist.pl_secondary_owner_key1,
	               plhist.pl_secondary_owner_key2, 
	               plhist.pl_secondary_owner_key3,
	               plhist.real_port_num,
	               plhist.pl_amt
          from dbo.pl_history plhist 
                 join #port_data pd on 
	                  plhist.pl_asof_date = pd.pl_asof_date and
	                  plhist.real_port_num = pd.real_port_num	
          where exists (select 1
                        from #pltypes typ
                        where plhist.pl_type <> typ.pl_type) and	                
	              plhist.pl_cost_prin_addl_ind is NULL and
	              plhist.pl_secondary_owner_key1 <> 0) pl
	  where exists (select 1
	                from dbo.trade_item_dist tid
	                where pl.pl_secondary_owner_key1 = tid.trade_num and
	                      pl.pl_secondary_owner_key2 = tid.order_num and
	                      pl.pl_secondary_owner_key3 = tid.item_num and
	                      pl.real_port_num = tid.real_port_num)
    group by pl.pl_secondary_owner_key1,
	           pl.pl_secondary_owner_key2,
	           pl.pl_secondary_owner_key3,
	           pl.real_port_num
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   drop table #port_data


   insert into #ti_data 
       (trade_num, order_num, item_num, real_port_num, 
        curr_pl_amt, pl_amt, due_date)
     select pl.pl_secondary_owner_key1,
	          pl.pl_secondary_owner_key2,
	          pl.pl_secondary_owner_key3,
	          pl.real_port_num,
	          sum(pl.pl_amt),
	          sum(pl.pl_amt),
	          max(pl_realization_date)
     from (select plhist.pl_record_key,
		              plhist.pl_secondary_owner_key1,  
	                plhist.pl_secondary_owner_key2,
	                plhist.pl_secondary_owner_key3,
	                plhist.real_port_num,
	                plhist.pl_amt,
	                plhist.pl_realization_date     
           from dbo.pl_history plhist 	
           where plhist.pl_asof_date = @my_pl_asof_date and
                 exists (select 1
                         from #portnums p
                         where p.port_num = plhist.real_port_num) and
                 exists (select 1
                         from #pltypes typ
                         where plhist.pl_type <> typ.pl_type) and
	               plhist.pl_cost_prin_addl_ind = 'P' and
	               plhist.pl_secondary_owner_key1 <> 0
           union
           select plhist.pl_record_key,
                  plhist.pl_secondary_owner_key1,
	                plhist.pl_secondary_owner_key2,
	                plhist.pl_secondary_owner_key3,
	                plhist.real_port_num,
	                plhist.pl_amt,
	                plhist.pl_realization_date     
           from dbo.pl_history plhist 	
           where plhist.pl_asof_date = @my_pl_asof_date and
                 exists (select 1
                         from #portnums p
                         where p.port_num = plhist.real_port_num) and
                 exists (select 1
                         from #pltypes typ
                         where plhist.pl_type <> typ.pl_type) and
	               plhist.pl_cost_prin_addl_ind is NULL and
	               plhist.pl_secondary_owner_key1 <> 0) pl
	  where exists (select 1
	                from dbo.trade_item_dist tid
	                where pl.pl_secondary_owner_key1 = tid.trade_num and
	                      pl.pl_secondary_owner_key2 = tid.order_num and
	                      pl.pl_secondary_owner_key3 = tid.item_num and
	                      pl.real_port_num = tid.real_port_num)
    group by pl.pl_secondary_owner_key1,
	           pl.pl_secondary_owner_key2,
	           pl.pl_secondary_owner_key3,
	           pl.real_port_num
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end


   update #ti_data
   set	counterparty = ac.acct_full_name, 
	      booking_company = bc.acct_full_name,
	      cmdty_full_name = cm.cmdty_full_name,
	      contract_date = t.contr_date,
	      inhouse_ind = t.inhouse_ind,
	      inhouse_real_port_num = 
	          case t.port_num when data.real_port_num 
	                             then ti.real_port_num 
	                          else t.port_num 
	          end,
	      trader_init = t.trader_init,
	      item_type = ti.item_type,
	      p_s_ind = ti.p_s_ind,
	      formula_ind = ti.formula_ind,
	      avg_price = ti.avg_price,
	      price_uom_code = ti.price_uom_code,
	      price_curr_code = ti.price_curr_code,
	      dist_qty = tid.dist_qty,
	      qty_uom_code = tid.qty_uom_code,
	      trading_prd_desc = tp.trading_prd_desc,
	      port_short_name = p.port_short_name,
	      bbl_qty = 0.0,
	      cmdty_code = ti.cmdty_code,
	      commkt_key = tid.commkt_key,
	      order_type_code = tor.order_type_code
   from #ti_data data
            join dbo.trade_item ti 
               on	ti.trade_num = data.trade_num and
	                ti.order_num = data.order_num and
	                ti.item_num = data.item_num
            join dbo.trade_order tor 
               on tor.trade_num = data.trade_num and
	                tor.order_num = data.order_num 
            join dbo.trade t 
               on t.trade_num = data.trade_num
            left outer join dbo.account ac 
               on	ac.acct_num  = t.acct_num
            join dbo.account bc 
               on bc.acct_num = ti.booking_comp_num
            join dbo.commodity cm 
               on cm.cmdty_code = ti.cmdty_code
            join dbo.trade_item_dist tid 
               on ti.trade_num = tid.trade_num and 
                  ti.order_num = tid.order_num and 
                  ti.item_num = tid.item_num and
		              data.real_port_num = tid.real_port_num and
	                tid.dist_type = 'D' 
            left outer join dbo.trading_period tp 
               on tp.commkt_key = tid.commkt_key and 
                  tp.trading_prd = tid.trading_prd
            join dbo.portfolio p 
               on p.port_num = data.real_port_num
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   insert into #uomconv 
       (qty_uom_code, price_uom_code, cmdty_code, conv_rate)
     select distinct qty_uom_code, 'BBL', cmdty_code, 0.0
     from #ti_data
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end
   
   select @oid = min(oid)
   from #uomconv 
    
   while @oid is not null
   begin
      select @qty_uom_code = qty_uom_code,
             @price_uom_code = price_uom_code, 
             @cmdty_code = cmdty_code
      from #uomconv
      where oid = @oid
       
      update #uomconv
      set conv_rate = dbo.udf_getUomConversion(@qty_uom_code, @price_uom_code, NULL, NULL, @cmdty_code)  
      where oid = @oid
      select @errcode = @@error
      if @errcode > 0
      begin
         select @status = 1
         goto endofsp
      end
       
      select @oid = min(oid)
      from #uomconv 
      where oid > @oid            
   end  
     
   update data
   set bbl_qty = case conv.qty_uom_code 
	                      when 'LOTS' then 0.0 
	                      else dist_qty * conv.conv_rate	                     
	               end
   from #ti_data data,
        #uomconv conv
   where isnull(data.qty_uom_code, '@@@') = isnull(conv.qty_uom_code, '@@@') and
         isnull(data.price_uom_code, '@@@') = isnull(conv.price_uom_code, '@@@') and
         isnull(data.cmdty_code, '@@@') = isnull(conv.cmdty_code, '@@@')
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   update data
   set accum_start_date = (select min(acc.accum_start_date) 
				                   from dbo.accumulation acc 
					                 where	data.trade_num = acc.trade_num and
						                      data.order_num = acc.order_num and 
						                      data.item_num = acc.item_num and
                                  accum_end_date = (select max(acc1.accum_end_date) 
	                                                  from dbo.accumulation acc1 
		                                                where	acc.trade_num = acc1.trade_num and
				                                                  acc.order_num = acc1.order_num and 
					                                                acc.item_num = acc1.item_num))
   from #ti_data data
   where formula_ind = 'Y'
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   update data
   set put_call_ind = tiopt.put_call_ind,
       premium_price = tiopt.premium,
       strike_price = tiopt.strike_price
   from #ti_data data
           join dbo.trade_item_otc_opt tiopt 
              on tiopt.trade_num = data.trade_num and
	               tiopt.order_num = data.order_num and
	               tiopt.item_num = data.item_num
   where item_type = 'O'

   update data
   set put_call_ind = tiopt.put_call_ind,
       premium_price = tiopt.premium,
       strike_price = tiopt.strike_price
   from #ti_data data
           join dbo.trade_item_exch_opt tiopt 
              on tiopt.trade_num = data.trade_num and
	               tiopt.order_num = data.order_num and
	               tiopt.item_num = data.item_num
   where item_type = 'E'
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   truncate table #uomconv
   insert into #uomconv 
       (qty_uom_code, price_uom_code, cmdty_code, conv_rate)
    select distinct qty_uom_code, price_uom_code, cmdty_code, 1.0
    from #ti_data
    where item_type = 'W'
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end
   
   select @oid = min(oid)
   from #uomconv 
    
   while @oid is not null
   begin
      select @qty_uom_code = qty_uom_code,
             @price_uom_code = price_uom_code, 
             @cmdty_code = cmdty_code
      from #uomconv
      where oid = @oid
       
      update #uomconv
      set conv_rate = dbo.udf_getUomConversion(@qty_uom_code, @price_uom_code, NULL, NULL, @cmdty_code)  
      where oid = @oid
      select @errcode = @@error
      if @errcode > 0
      begin
         select @status = 1
         goto endofsp
      end
       
      select @oid = min(oid)
      from #uomconv 
      where oid > @oid            
   end  

   update data
   set extended_value = 
          case when inhouse_ind = 'N' AND p_s_ind = 'P' 
                  then avg_price * conv.conv_rate * -1.0
			         when inhouse_ind = 'N' AND p_s_ind = 'S' 
			            then avg_price * dist_qty * conv.conv_rate
			         when inhouse_ind = 'Y' AND p_s_ind = 'P' 
			            then avg_price * dist_qty * conv.conv_rate
			         when inhouse_ind = 'Y' AND p_s_ind = 'S' 
			            then avg_price * dist_qty * conv.conv_rate * -1.0
			    end
   from #ti_data data,
        #uomconv conv
   where item_type = 'W' and
         isnull(data.qty_uom_code, '@@@') = isnull(conv.qty_uom_code, '@@@') and
         isnull(data.price_uom_code, '@@@') = isnull(conv.price_uom_code, '@@@') and
         isnull(data.cmdty_code, '@@@') = isnull(conv.cmdty_code, '@@@')
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   -- get data for day P/L
   update data
   set data.curr_pl_amt = isnull(data.curr_pl_amt, 0.0) - isnull(pt.curr_pl_amt, 0.0)
   from #ti_data data
           join #prev_pl pt 
              on data.trade_num = pt.trade_num and 
                 data.order_num = pt.order_num and
                 data.item_num = pt.item_num and
                 data.real_port_num = pt.real_port_num
   select @errcode = @@error
   if @errcode > 0
   begin
      select @status = 1
      goto endofsp
   end

   -- output result
   select convert(varchar, trade_num) + '/' + 
             convert(varchar, order_num) + '/' + 
             convert(varchar, item_num) as Column01,
	        booking_company as Column02,
	        convert(varchar, contract_date, 101) as Column03,
	        trader_init as Column04,
	        case inhouse_ind when 'Y' then 'Inhouse with portfolio ' + 
	                                          convert(varchar, inhouse_real_port_num) 
	                         else counterparty 
	        end as Column05, 
	        real_port_num as Column06,
	        port_short_name as Column07,
	        trading_prd_desc as Column08,
	        convert(varchar, accum_start_date, 106) + '-' + 
	                  convert(varchar, accum_end_date, 106) as Column09,
	        case inhouse_ind when 'Y' then NULL 
	                         else convert(varchar, due_date, 106) 
	        end as Column10,
	        case item_type when 'C' then 'SWAP' 
	                       when 'W' then 'PHYSICAL' 
	                       when 'F' then 'FUTURE' 
	                       else item_type 
	        end as Column11,
	        cmdty_full_name as Column12,
	        p_s_ind as Column13,
	        put_call_ind as Column14, 
	        dist_qty as Column15,
	        qty_uom_code as Column16,
	        bbl_qty as Column17,
	        avg_price as Column18, 
	        strike_price as Column19, 
	        premium_price as Column20, 
	        extended_value as Column21, 
          curr_pl_amt as Column22,
	        pl_amt as Column23
   from #ti_data
   order by real_port_num, trade_num, order_num, item_num
   goto endofsp
   
reportusage:
   print ' '
   print @smsg
   print 'Usage: exec dbo.tabbed_pl_data @pl_asof_date = ''mm/dd/yyyy'','
   print '                           @port_num_list = ''?'''
   print '        Here, the @port_num_list consists of a number of port_num(s)'
   print '           separated by a '','''
   print ' '
   select @status = 2

endofsp:
   drop table #prev_pl
   drop table #ti_data
   drop table #pltypes
   drop table #portnums
return @status
GO
GRANT EXECUTE ON  [dbo].[tabbed_pl_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'tabbed_pl_data', NULL, NULL
GO
