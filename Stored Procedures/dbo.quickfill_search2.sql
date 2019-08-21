SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_search2]
(
   @fromDate varchar(30) = null,
   @toDate varchar(30) = null,
   @creatorInit char(3) = null
)
as
set nocount on

   if (@fromDate is null) and (@toDate is null) and (@creatorInit is null)
      return -584

   if (@fromDate is null) and (@toDate is null) 
   begin
      if (@creatorInit is not null) 
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
                o.order_strategy_name
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and 
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
            t.inhouse_ind in ('N', NULL)               
   else if (@creatorInit is null)
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
             o.order_strategy_name	
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
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
      where order_type_code in (select order_type_code from #orderTypes)
      and t.inhouse_ind in ('N', NULL)               
   end
   else if (@fromDate is null) and (@toDate is not null) 
   begin
      if (@creatorInit is not null) 
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
                o.order_strategy_name
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and
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
              t.contr_date <= @toDate and 
              t.inhouse_ind in ('N', NULL)               
     else if (@creatorInit is null) 
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
               o.order_strategy_name
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
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
              t.contr_date <= @toDate and 
              t.inhouse_ind in ('N', NULL)               
   end
   else 
   begin
      if (@creatorInit is not null) 
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
                o.order_strategy_name
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and
               t.contr_date >= @fromDate and 
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
              t.inhouse_ind in ('N', NULL)               
      else if (@creatorInit is null)
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
                o.order_strategy_name
/******************************************************************************                	
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.contr_date >= @fromDate and 
               t.inhouse_ind in ('N', null) and
               t.trade_num = o.trade_num and 
               t.trade_num *= e.trade_num and 
               o.order_num *= e.order_num
******************************************************************************/
        from dbo.trade t
                inner join trade_order o
                   on t.trade_num = o.trade_num
                left outer join trade_order_in_exch e
                   on t.trade_num = e.trade_num and 
                      o.order_num = e.order_num
        where order_type_code in (select order_type_code from #orderTypes) and 
              t.contr_date >= @fromDate and 
              t.inhouse_ind in ('N', NULL)               
   end
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_search2] TO [next_usr]
GO
