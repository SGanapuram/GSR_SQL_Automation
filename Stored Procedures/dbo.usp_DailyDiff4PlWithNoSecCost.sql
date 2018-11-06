SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_DailyDiff4PlWithNoSecCost]
(
   @port_num           int,
   @asofdate           datetime
)
as
set nocount on
declare @total_pl_no_sec_cost_curr     numeric(20, 8),
        @total_pl_no_sec_cost_prev     numeric(20, 8)

   if not exists (select 1
                  from dbo.portfolio
                  where port_num = @port_num)
   begin
      print 'Usage: dbo.usp_DailyDiff4PlWithNoSecCost @port_num = ?, @asofdate = ''?'''
      print '=> You must provide a valid value for the argument @port_num!'
      goto endofsp
   end
        
   select @total_pl_no_sec_cost_curr = isnull(total_pl_no_sec_cost, 0.0)
   from dbo.portfolio_profit_loss 
   where port_num = @port_num and
         pl_asof_date = @asofdate
         
   select @total_pl_no_sec_cost_prev = isnull(total_pl_no_sec_cost, 0.0)
   from dbo.portfolio_profit_loss portpl1
   where port_num = @port_num and
         pl_asof_date = (select max(pl_asof_date)
                         from dbo.portfolio_profit_loss portpl2
                         where portpl1.port_num = portpl2.port_num and
                               portpl2.pl_asof_date < @asofdate)
                               
   select (@total_pl_no_sec_cost_curr - @total_pl_no_sec_cost_prev) as 'Day Diff (current - prev)'

endofsp:
GO
GRANT EXECUTE ON  [dbo].[usp_DailyDiff4PlWithNoSecCost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_DailyDiff4PlWithNoSecCost', NULL, NULL
GO
