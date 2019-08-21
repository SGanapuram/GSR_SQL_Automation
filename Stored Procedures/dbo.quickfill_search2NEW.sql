SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_search2NEW]
(
   @fromDate      varchar(30) = null,
   @toDate        varchar(30) = null,
   @creatorInit   char(1) = null,
   @inhouseind    varchar(10) = null,
   @tradefromdate varchar(30) = null,
   @tradetodate   varchar(30) = null
)
as
set nocount on

   if (@fromDate is null) and (@toDate is null) and (@creatorInit = 'N')
      return -584

   if (@fromDate is null) and (@toDate is null) 
   begin
      if (@creatorInit <> 'N') 
      begin
         if @tradefromdate is null and @tradetodate is null 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
         else if @tradefromdate is not null and @tradetodate is not null
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.creation_date <= @tradefromdate and
                  t.creation_date >= @tradetodate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
      end
      else if (@creatorInit = 'N')
      begin 
         if @tradefromdate is null and @tradetodate is null 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
         else if @tradefromdate is not null and @tradetodate is not null
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creation_date <= @tradefromdate and
                  t.creation_date >= @tradetodate  and 
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
      end
   end
   else if (@fromDate is null) and (@toDate is not null) 
   begin
      if (@creatorInit <> 'N')
      begin
         if @tradefromdate is null and @tradetodate is null 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date <= @toDate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
         else if @tradefromdate is not null and @tradetodate is not null 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date <= @toDate and
                  t.creation_date <= @tradefromdate and
                  t.creation_date >= @tradetodate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
      end
      else if (@creatorInit = 'N') 
      begin
         if @tradefromdate is null and @tradetodate is null
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.contr_date <= @toDate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
         else if @tradefromdate is not null and @tradetodate is not null
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.contr_date <= @toDate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.creation_date <= @tradefromdate and
                  t.creation_date >= @tradetodate and
                  t.trade_num = o.trade_num
      end
   end
   else 
   begin
      if (@creatorInit <> 'N')
      begin
         if @tradefromdate is null and @tradetodate is null 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date >= @fromDate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
         else if @tradefromdate is not null and @tradetodate is not null 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date >= @fromDate and
                  t.creation_date <= @tradefromdate and
                  t.creation_date >= @tradetodate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
      end
      else if (@creatorInit = 'N')
      begin
         if @tradefromdate is null and @tradetodate is null
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.contr_date >= @fromDate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
         else if @tradefromdate is not null and @tradetodate is not null
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   t.trader_init,
                   t.trade_status_code,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   e.order_price,
                   e.order_price_curr_code,
                   e.order_points,
                   e.order_instr_code,
                   o.order_strategy_name,
                   t.inhouse_ind
            from dbo.trade t 
                    left outer join dbo.trade_order o
                       on t.trade_num = o.trade_num 
                    left outer join dbo.trade_order_on_exch e
                       on o.order_num = e.order_num
            where o.order_type_code in (select order_type_code from #orderTypes) and
                  t.contr_date >= @fromDate and
                  t.creation_date <= @tradefromdate and
                  t.creation_date >= @tradetodate and
                  t.inhouse_ind in (select * from dbo.fnToSplit(@inhouseind, ',')) and
                  t.trade_num = o.trade_num
      end          
   end
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_search2NEW] TO [next_usr]
GO
