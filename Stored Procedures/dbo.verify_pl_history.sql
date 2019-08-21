SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[verify_pl_history]
(
   @pl_asof_date datetime = NULL
)
as
set nocount on
declare @port_num           int,
        @history_pl         float,
        @pl_pl              float,
        @my_pl_asof_date    datetime

   if (@pl_asof_date is null)
   begin
      print 'Usage: exec verify_pl_history @pl_asof_date = ''<a valid date>''!'
      return
   end

   select @my_pl_asof_date = @pl_asof_date
   create table #portpldiff (
      port_num     int   not null,
      history_pl   float default 0 null,
      pl_pl        float default 0 null)

   insert into #portpldiff (port_num)
   select distinct pl.port_num
   from dbo.portfolio_profit_loss pl,
        dbo.portfolio p,
        dbo.pl_history history
   where p.port_type = 'R' and
         p.port_num = pl.port_num and
         pl.pl_asof_date = @my_pl_asof_date and
         history.pl_type not in ('I', 'W') and
         history.real_port_num = p.port_num and
         history.pl_asof_date = @my_pl_asof_date

   update #portpldiff
   set history_pl = (select sum(isnull(pl_amt, 0))
                     from dbo.pl_history
                     where real_port_num = #portpldiff.port_num and
                           pl_asof_date = @my_pl_asof_date and
                           pl_type not in ('I', 'W')
                     group by real_port_num)


   update #portpldiff
   set pl_pl = pl.open_phys_pl + pl.closed_phys_pl + pl.open_hedge_pl + pl.closed_hedge_pl 
               + pl.liq_closed_phys_pl + pl.liq_closed_hedge_pl
   from dbo.portfolio_profit_loss pl
   where pl.port_num = #portpldiff.port_num and
         pl.pl_asof_date = @my_pl_asof_date

   select port_num,
          history_pl,
          pl_pl,
          diff = history_pl - pl_pl
   from #portpldiff
   order by port_num, diff

   drop table #portpldiff
   return 0
GO
GRANT EXECUTE ON  [dbo].[verify_pl_history] TO [next_usr]
GO
