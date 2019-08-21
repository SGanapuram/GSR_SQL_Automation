SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_daily_paper_pnl]
(  
   @pl_asof_date        datetime = null, 
   @port_nums	          varchar(max) = null,
   @dept_code	          varchar(50) = null,
   @desk_code	          varchar(50) = null, 
   @debugon             bit = 0  
)
as  
set nocount on
declare @rows_affected		int,  
        @smsg			        varchar(255),  
        @status			      int,  
        @oid			        numeric(18, 0),  
        @stepid			      smallint,  
        @session_started	varchar(30),  
        @session_ended		varchar(30),
        @my_pl_asof_date	datetime,
	      @my_port_nums		  varchar(8000)

   select	@my_pl_asof_date = @pl_asof_date,
		      @my_port_nums	= @port_nums

   create table #temp1
   (
      dept_code		    char(8),
      curr_code	  	  char(8),
      realized_pl	    decimal(20, 8),
      unrealized_pl	  decimal(20, 8),
      total_pl		    decimal(20, 8)
   )
   insert into #temp1 
      exec dbo.usp_daily_paper_pl_report @my_pl_asof_date, @my_port_nums, @dept_code, @desk_code, 0

   set @my_pl_asof_date = (select max(pl_asof_date) 
                           from dbo.portfolio_profit_loss 
                           where pl_asof_date < @pl_asof_date)

   create table #temp2
   (
	    dept_code		  char(8),
      curr_code		  char(8),
      realized_pl		decimal(20, 8),
      unrealized_pl	decimal(20, 8),
      total_pl		  decimal(20, 8)
   )
   insert into #temp2 
      exec dbo.usp_daily_paper_pl_report @my_pl_asof_date, @my_port_nums, @dept_code, @desk_code, 0

   set @my_pl_asof_date = (select max(pl_asof_date) 
                           from dbo.portfolio_profit_loss 
                           where pl_asof_date < @pl_asof_date and 
                                 is_month_end_ind = 'Y')

   create table #temp3
   (
	    dept_code		  char(8),
      curr_code		  char(8),
      realized_pl		decimal(20, 8),
      unrealized_pl	decimal(20, 8),
      total_pl		  decimal(20, 8)
   )
   insert into #temp3 
      exec dbo.usp_daily_paper_pl_report @my_pl_asof_date, @my_port_nums, @dept_code, @desk_code, 0

   create table #output
   (
      dept_code         char(8),
      curr_code         char(8),
      realized_pl       decimal(20, 8),
      unrealized_pl     decimal(20, 8),
      total_pl          decimal(20, 8),
      day_change_pl     decimal(20, 8),
      month_change_pl   decimal(20, 8)
   )

   insert into #output
   (
      dept_code,
      curr_code,
      realized_pl,
      unrealized_pl,
      total_pl
   )
   select * 
   from #temp1 
   where curr_code is not null

   update t1
   set day_change_pl = t1.total_pl - t2.total_pl
   from #output t1, 
        #temp2 t2
   where t1.dept_code = t2.dept_code and 
         t1.curr_code = t2.curr_code

   update t1
   set month_change_pl = t1.total_pl - t2.total_pl
   from #output t1, 
        #temp3 t2
   where t1.dept_code = t2.dept_code and 
         t1.curr_code = t2.curr_code

   create table #reverse
   (
	    item_type    varchar(20),
	    CRUDE	       decimal(20, 6),
	    Products	   decimal(20, 6)
   )

   insert into #reverse values('Realized P/L',0,0)
   insert into #reverse values('Floating P/L',0,0)
   insert into #reverse values('Accumulative P/L',0,0)
   insert into #reverse values('Daily Change',0,0)
   insert into #reverse values('Monthly Change',0,0)

   update #reverse
   set CRUDE = t1.realized_pl
   from #output t1
   where t1.dept_code = 'CRUDE' and 
         item_type = 'Realized P/L'

   update #reverse
   set Products = t1.realized_pl
   from #output t1
   where t1.dept_code = 'PRODUCTS' and 
         item_type = 'Realized P/L'

   update #reverse
   set CRUDE = t1.unrealized_pl
   from #output t1
   where t1.dept_code = 'CRUDE' and 
         item_type = 'Floating P/L'

   update #reverse
   set Products = t1.unrealized_pl
   from #output t1
   where t1.dept_code='PRODUCTS' and 
         item_type = 'Floating P/L'

   update #reverse
   set CRUDE = t1.total_pl
   from #output t1
   where t1.dept_code = 'CRUDE' and 
         item_type = 'Accumulative P/L'

   update #reverse
   set Products = t1.total_pl
   from #output t1
   where t1.dept_code = 'PRODUCTS' and 
         item_type = 'Accumulative P/L'

   update #reverse
   set CRUDE = t1.day_change_pl
   from #output t1
   where t1.dept_code = 'CRUDE' and 
         item_type = 'Daily Change'

   update #reverse
   set Products = t1.day_change_pl
   from #output t1
   where t1.dept_code = 'PRODUCTS' and 
         item_type = 'Daily Change'

   update #reverse
   set CRUDE = t1.month_change_pl
   from #output t1
   where t1.dept_code = 'CRUDE' and 
         item_type = 'Monthly Change'

   update #reverse
   set Products = t1.month_change_pl
   from #output t1
   where t1.dept_code = 'PRODUCTS' and 
         item_type = 'Monthly Change'

   select * from #reverse

   drop table #reverse
   drop table #temp1
   drop table #temp2
   drop table #temp3
   drop table #output

endofsp:
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_daily_paper_pnl] TO [next_usr]
GO
