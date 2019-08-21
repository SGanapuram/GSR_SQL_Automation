SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_search1]
(
   @fromDate varchar(30) = null,
   @toDate varchar(30) = null,
   @creatorInit char(3) = null
)
as
set nocount on

/* This stored procedure uses the following temporary tables:
      create table #flattrade_view
      (
        trade_num int not null,
        order_num smallint not null,
        order_type_code varchar(8) not null,
        trader_init char(3) null,
        trade_status_code varchar(8) null,
        contr_date datetime null,
        creation_date datetime null,
        creator_init char(3) null,
        order_price float null,
        order_price_curr_code char(8) null,
        order_points float null,
        order_instr_code varchar(8) null,
        order_strategy_name varchar(15) null
     )
     create table #orderTypes (order_type_code varchar(8) not null)
     create table #creatorInit (creator_init char(3) null)
     create table #traderInit (trader_init char(3) null)
*/

   if (@fromDate is null) and (@toDate is null) and (@creatorInit is null) 
      return -584

   if (@fromDate is not null) and (@toDate is not null) 
   begin
      if (datediff(day, @fromDate, @toDate) = 0) 
      begin
         if (@creatorInit is not null) 
            insert into #flattrade_view 
            select 
                t.trade_num,
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
                o.order_strategy_name
/******************************************************************************                
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.creator_init in (select creator_init from #creatorInit) and 
                  t.contr_date = @fromDate and
                  t.inhouse_ind in ('N', null) and
                  t.trade_num = o.trade_num and 
                  t.trade_num *= e.trade_num and 
                  o.order_num *= e.order_num
******************************************************************************/
            from dbo.trade t
                    inner join dbo.trade_order o
                       on t.trade_num = o.trade_num
                    left outer join dbo.trade_order_on_exch e
                       on t.trade_num = e.trade_num and 
                          o.order_num = e.order_num
            where order_type_code in (select order_type_code from #orderTypes) and
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date = @fromDate and
                  t.inhouse_ind in ('N', NULL)                  
         else if (@creatorInit is null) 
            insert into #flattrade_view 
            select 
                t.trade_num,
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
                o.order_strategy_name
/******************************************************************************                
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.contr_date = @fromDate and
                  t.inhouse_ind in ('N', null) and
                  t.trade_num = o.trade_num and 
                  t.trade_num *= e.trade_num and 
                  o.order_num *= e.order_num
******************************************************************************/
            from dbo.trade t
                    inner join dbo.trade_order o
                       on t.trade_num = o.trade_num
                    left outer join dbo.trade_order_on_exch e
                       on t.trade_num = e.trade_num and 
                          o.order_num = e.order_num
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.contr_date = @fromDate and 
                  t.inhouse_ind in ('N', NULL)                  
      end
      else 
      begin
         if (@creatorInit is not null) 
            insert into #flattrade_view 
            select 
                t.trade_num,
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
                o.order_strategy_name
/******************************************************************************                
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date >= @fromDate and
                  t.contr_date <= @toDate and 
                  t.inhouse_ind in ('N', null) and
                  t.trade_num = o.trade_num and 
                  t.trade_num *= e.trade_num and 
                  o.order_num *= e.order_num
******************************************************************************/
            from dbo.trade t
                    inner join dbo.trade_order o
                       on t.trade_num = o.trade_num
                    left outer join dbo.trade_order_on_exch e
                       on t.trade_num = e.trade_num and 
                          o.order_num = e.order_num
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date >= @fromDate and
                  t.contr_date <= @toDate and
                  t.inhouse_ind in ('N', NULL)                  
         else if (@creatorInit is null) 
            insert into #flattrade_view 
            select 
                t.trade_num,
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
                o.order_strategy_name
/******************************************************************************                
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.contr_date >= @fromDate and
                  t.contr_date <= @toDate and 
                  t.inhouse_ind in ('N', null) and
                  t.trade_num = o.trade_num and 
                  t.trade_num *= e.trade_num and 
                  o.order_num *= e.order_num
******************************************************************************/
            from dbo.trade t
                    inner join dbo.trade_order o
                       on t.trade_num = o.trade_num
                    left outer join dbo.trade_order_on_exch e
                       on t.trade_num = e.trade_num and 
                          o.order_num = e.order_num
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.contr_date >= @fromDate and 
                  t.contr_date <= @toDate and 
                  t.inhouse_ind in ('N', NULL)                  
      end
   end
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_search1] TO [next_usr]
GO
