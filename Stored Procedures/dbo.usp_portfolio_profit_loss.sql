SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_portfolio_profit_loss]
(
   @pl_asof_date  datetime = NULL,
   @port_num      int = 0
)
as
set nocount on
declare @l_port_num       int,
        @l_pl_asof_date   datetime

   select @l_port_num = isnull(@port_num, 0),
          @l_pl_asof_date = @pl_asof_date

   if @l_port_num <> 0
   begin
      if not exists (select 1
                     from dbo.portfolio with (nolock)
                     where port_num = @l_port_num)
      begin
         print 'You must provide a valid port_num for the argument @port_num!'
         goto reportusage
      end
   end
   
   create table #pl_temp 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      open_phys_pl         numeric(38, 8)  NULL,
      open_hedge_pl        numeric(38, 8)  NULL,
      closed_phys_pl       numeric(38, 8)  NULL,
      closed_hedge_pl      numeric(38, 8)  NULL,
      liq_closed_phys_pl   numeric(38, 8)  NULL,
      liq_closed_hedge_pl  numeric(38, 8)  NULL,
      is_week_end_ind      char(1)         NULL,
      is_month_end_ind     char(1)         NULL,
      is_year_end_ind      char(1)         NULL,
      is_compyr_end_ind    char(1)         NULL
   )

   create table #open_phys_pl 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      pl_amt               numeric(38, 8)  NULL
   )
   create table #open_hedge_pl 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      pl_amt               numeric(38, 8)  NULL
   )
   create table #closed_phys_pl 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      pl_amt               numeric(38, 8)  NULL
   )
   create table #closed_hedge_pl 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      pl_amt               numeric(38, 8)  NULL
   )
   create table #liq_closed_phys_pl 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      pl_amt               numeric(38, 8)  NULL
   )
   create table #liq_closed_hedge_pl 
   (
      port_num             int             NOT NULL,
      pl_asof_date         datetime        NOT NULL,
      pl_amt               numeric(38, 8)  NULL
   )

   create nonclustered index pl_temp_idx999
        on #pl_temp (port_num, pl_asof_date)

   -- no port_num passed in
   if @l_port_num = 0
   begin
      -- no pl_asof_date passed in
      if @l_pl_asof_date is null
      begin
         insert into #open_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from (select real_port_num,
                      pl_asof_date, 
                      pl_amt
               from dbo.pl_history plh1
               where exists (select 1
                             from dbo.position pos
                             where plh1.pos_num = pos.pos_num and
                                   pos.is_hedge_ind = 'N') and
                     plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code != 'P'
               union all
               select real_port_num,
                      pl_asof_date, 
                      pl_amt
               from dbo.pl_history plh1      
               where plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code = 'P' ) plh
         group by plh.real_port_num,
                  plh.pl_asof_date

         insert into #open_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type in ('O','U','R','M') and
               plh.pl_owner_code != 'P'
         group by plh.real_port_num,
                  plh.pl_asof_date

         insert into #closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'C'
         group by plh.real_port_num,
                  plh.pl_asof_date

         insert into #closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'C'
         group by plh.real_port_num,
                  plh.pl_asof_date

         insert into #liq_closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'L'
         group by plh.real_port_num,
                  plh.pl_asof_date

         insert into #liq_closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'L'
         group by plh.real_port_num,
                  plh.pl_asof_date

      end
      -- pl_asof_date passed in
      else
      begin
         insert into #open_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from (select real_port_num,
                      pl_asof_date, 
                      pl_amt
               from dbo.pl_history plh1
               where exists (select 1
                             from dbo.position pos
                             where plh1.pos_num = pos.pos_num and
                                   pos.is_hedge_ind = 'N') and
                     plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code != 'P' and
                     plh1.pl_asof_date = @l_pl_asof_date
               union all
               select real_port_num,
                      pl_asof_date, 
                      pl_amt
               from dbo.pl_history plh1      
               where plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code = 'P' and
                     plh1.pl_asof_date = @l_pl_asof_date) plh
         group by plh.real_port_num

         insert into #open_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type in ('O','U','R','M') and
               plh.pl_owner_code != 'P' and
               plh.pl_asof_date = @l_pl_asof_date
         group by plh.real_port_num

         insert into #closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'C' and
               plh.pl_asof_date = @l_pl_asof_date
         group by plh.real_port_num

         insert into #closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'C' and
               plh.pl_asof_date = @l_pl_asof_date
         group by plh.real_port_num

         insert into #liq_closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'L' and
               plh.pl_asof_date = @l_pl_asof_date
         group by plh.real_port_num

         insert into #liq_closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.real_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'L' and
               plh.pl_asof_date = @l_pl_asof_date
         group by plh.real_port_num
      end
   end
   -- port_num passed in
   else
   begin
      -- no pl_asof_date passed in
      if @l_pl_asof_date is null
      begin
         insert into #open_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from (select real_port_num,
                      pl_asof_date, 
                      pl_amt
               from dbo.pl_history plh1
               where exists (select 1
                             from dbo.position pos
                             where plh1.pos_num = pos.pos_num and
                                   pos.is_hedge_ind = 'N') and
                     plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code != 'P' and
                     plh1.real_port_num = @l_port_num
               union all
               select real_port_num,
                      pl_asof_date, 
                      pl_amt
               from dbo.pl_history plh1      
               where plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code = 'P' and
                     plh1.real_port_num = @l_port_num) plh
         group by plh.pl_asof_date

         insert into #open_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type in ('O','U','R','M') and
               plh.pl_owner_code != 'P' and
               plh.real_port_num = @l_port_num
         group by plh.pl_asof_date

         insert into #closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'C' and
               plh.real_port_num = @l_port_num
         group by plh.pl_asof_date

         insert into #closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'C' and
               plh.real_port_num = @l_port_num
         group by plh.pl_asof_date

         insert into #liq_closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'L' and
               plh.real_port_num = @l_port_num
         group by plh.pl_asof_date

         insert into #liq_closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'L' and
               plh.real_port_num = @l_port_num
         group by plh.pl_asof_date
      end
      -- pl_asof_date passed in
      else
      begin
         insert into #open_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select plh.port_num,
                plh.pl_asof_date,
                sum(plh.pl_amt)
         from (select @l_port_num as port_num,
                      @l_pl_asof_date as pl_asof_date,
                      pl_amt
               from dbo.pl_history plh1
               where exists (select 1
                             from dbo.position pos
                             where plh1.pos_num = pos.pos_num and
                                   pos.is_hedge_ind = 'N') and
               plh1.pl_type in ('O','U','R','M') and
               plh1.pl_owner_code != 'P' and
               plh1.pl_asof_date = @l_pl_asof_date and 
               plh1.real_port_num = @l_port_num
               union all
               select @l_port_num as port_num,
                      @l_pl_asof_date as pl_asof_date,
                      pl_amt
               from dbo.pl_history plh1      
               where plh1.pl_type in ('O','U','R','M') and
                     plh1.pl_owner_code = 'P' and
                     plh1.pl_asof_date = @l_pl_asof_date and
                     plh1.real_port_num = @l_port_num) plh
         group by plh.port_num, plh.pl_asof_date

         insert into #open_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type in ('O','U','R','M') and
               plh.pl_owner_code != 'P' and
               plh.pl_asof_date = @l_pl_asof_date and 
               plh.real_port_num = @l_port_num

         insert into #closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'C' and
               plh.pl_asof_date = @l_pl_asof_date and 
               plh.real_port_num = @l_port_num

         insert into #closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'C' and
               plh.pl_asof_date = @l_pl_asof_date and 
               plh.real_port_num = @l_port_num

         insert into #liq_closed_phys_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'N') and
               plh.pl_type = 'L' and
               plh.pl_asof_date = @l_pl_asof_date and 
               plh.real_port_num = @l_port_num

         insert into #liq_closed_hedge_pl
            (port_num, pl_asof_date, pl_amt)
         select @l_port_num,
                @l_pl_asof_date,
                sum(plh.pl_amt)
         from dbo.pl_history plh
         where exists (select 1
                       from dbo.position pos
                       where plh.pos_num = pos.pos_num and
                             pos.is_hedge_ind = 'Y') and
               plh.pl_type = 'L' and
               plh.pl_asof_date = @l_pl_asof_date and 
               plh.real_port_num = @l_port_num
      end
   end

   -- need a list of all unique port_num, pl_asof_date combinations from all the #_pl tables
   insert into #pl_temp (port_num, pl_asof_date)
   select port_num, pl_asof_date
   from #open_phys_pl
   union
   select port_num, pl_asof_date
   from #open_hedge_pl
   union
   select port_num, pl_asof_date
   from #closed_phys_pl
   union
   select port_num, pl_asof_date
   from #closed_hedge_pl
   union
   select port_num, pl_asof_date
   from #liq_closed_phys_pl
   union
   select port_num, pl_asof_date
   from #liq_closed_hedge_pl

   update #pl_temp
   set open_phys_pl = opl.pl_amt,
       open_hedge_pl = ohl.pl_amt,
       closed_phys_pl = cpl.pl_amt,
       closed_hedge_pl = chl.pl_amt,
       liq_closed_phys_pl = lpl.pl_amt,
       liq_closed_hedge_pl = lhl.pl_amt,
       is_week_end_ind = ppl.is_week_end_ind,
       is_month_end_ind = ppl.is_month_end_ind,
       is_year_end_ind = ppl.is_year_end_ind,
       is_compyr_end_ind = ppl.is_compyr_end_ind
   from #pl_temp pd
        left outer join #open_phys_pl opl
            on pd.port_num = opl.port_num
            and pd.pl_asof_date = opl.pl_asof_date
        left outer join #open_hedge_pl ohl
            on pd.port_num = ohl.port_num
            and pd.pl_asof_date = ohl.pl_asof_date
        left outer join #closed_phys_pl cpl
            on pd.port_num = cpl.port_num
            and pd.pl_asof_date = cpl.pl_asof_date
        left outer join #closed_hedge_pl chl
            on pd.port_num = chl.port_num
            and pd.pl_asof_date = chl.pl_asof_date
        left outer join #liq_closed_phys_pl lpl
            on pd.port_num = lpl.port_num
            and pd.pl_asof_date = lpl.pl_asof_date
        left outer join #liq_closed_hedge_pl lhl
            on pd.port_num = lhl.port_num   
            and pd.pl_asof_date = lhl.pl_asof_date
        left outer join portfolio_profit_loss ppl
            on pd.port_num = ppl.port_num
            and pd.pl_asof_date = ppl.pl_asof_date      

   select pltemp.closed_hedge_pl,
          pltemp.closed_phys_pl,
          pltemp.is_compyr_end_ind,
          pltemp.is_month_end_ind,
          pltemp.is_week_end_ind,
          pltemp.is_year_end_ind,
          pltemp.liq_closed_hedge_pl,
          pltemp.liq_closed_phys_pl,
          pltemp.open_hedge_pl,
          pltemp.open_phys_pl,
          pltemp.pl_asof_date,
          pltemp.port_num,
          pl.total_pl_no_sec_cost
   from #pl_temp pltemp
           INNER JOIN dbo.portfolio_profit_loss pl
              ON pltemp.port_num = pl.port_num and
                 pltemp.pl_asof_date = pl.pl_asof_date
   order by pltemp.port_num,
            pltemp.pl_asof_date

   drop table #pl_temp
   drop table #open_phys_pl
   drop table #open_hedge_pl
   drop table #closed_phys_pl
   drop table #closed_hedge_pl
   drop table #liq_closed_phys_pl
   drop table #liq_closed_hedge_pl
   return 0

reportusage:
   print 'Usage: exec dbo.usp_portfolio_profit_loss [@pl_asof_date = ''?''] [, @port_num = ? ]'
   return 1
GO
GRANT EXECUTE ON  [dbo].[usp_portfolio_profit_loss] TO [next_usr]
GO
