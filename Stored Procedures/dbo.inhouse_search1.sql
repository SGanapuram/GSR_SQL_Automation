SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_search1]
(
   @fromDate varchar(30) = null,
   @toDate varchar(30) = null,
   @creatorInit char(3) = null
)
as
set nocount on

   if (@fromDate is null) and (@toDate is null) and (@creatorInit is null) 
      return -584

   if (@fromDate is not null) and (@toDate is not null) 
   begin
      if (datediff(day,@fromDate,@toDate) = 0) 
      begin
         if (@creatorInit is not null) 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   o.order_strategy_name,
                   t.trader_init,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   t.trade_mod_init,
                   t.port_num
/******************************************************************************                   
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.creator_init in (select creator_init from #creatorInit) and 
                  t.contr_date = @fromDate and
                  t.trade_num = o.trade_num and 
                  t.inhouse_ind = 'Y' and
                  t.trade_num *= e.trade_num and 
                  o.order_num *= e.order_num
******************************************************************************/
            from dbo.trade t
                    inner join dbo.trade_order o
                       on t.trade_num = o.trade_num
                    left outer join dbo.trade_order_on_exch e
                       on t.trade_num = e.trade_num and 
                          o.order_num = e.order_num
            where order_type_code in (select order_type_code 
                                      from #orderTypes) and 
                  t.creator_init in (select creator_init 
                                     from #creatorInit) and 
                  t.contr_date = @fromDate and 
                  t.inhouse_ind = 'Y'                  
         else if (@creatorInit is null) 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   o.order_strategy_name,
                   t.trader_init,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   t.trade_mod_init,
                   t.port_num
/******************************************************************************                   
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code 
                                      from #orderTypes) and 
                  t.contr_date = @fromDate and
                  t.inhouse_ind = 'Y' and
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
            where order_type_code in (select order_type_code 
                                      from #orderTypes) and 
                  t.contr_date = @fromDate and 
                  t.inhouse_ind = 'Y'
      end
      else 
      begin
         if (@creatorInit is not null) 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   o.order_strategy_name,
                   t.trader_init,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   t.trade_mod_init,
                   t.port_num
/******************************************************************************                   
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date >= @fromDate and
                  t.contr_date <= @toDate and 
                  t.inhouse_ind = 'Y' and
                  t.trade_num = o.trade_num and 
                  t.trade_num *= e.trade_num and 
                  o.order_num *= e.order_num
******************************************************************************/
            from dbo.trade t
                    inner join trade_order o
                       on t.trade_num = o.trade_num
                    left outer join trade_order_on_exch e
                       on t.trade_num = e.trade_num and 
                          o.order_num = e.order_num
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.creator_init in (select creator_init from #creatorInit) and
                  t.contr_date >= @fromDate and
                  t.contr_date <= @toDate and
                  t.inhouse_ind = 'Y'                  
         else if (@creatorInit is null) 
            insert into #flattrade_view 
            select t.trade_num,
                   o.order_num,
                   o.order_type_code,
                   o.order_strategy_name,
                   t.trader_init,
                   t.contr_date,
                   t.creation_date,
                   t.creator_init,
                   t.trade_mod_init,
                   t.port_num	
/******************************************************************************                   	
            from trade t, trade_order o, trade_order_on_exch e
            where order_type_code in (select order_type_code from #orderTypes) and 
                  t.contr_date >= @fromDate and
                  t.contr_date <= @toDate and 
                  t.inhouse_ind = 'Y' and
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
                  t.inhouse_ind = 'Y'                  
      end
   end
   else if (@fromDate is null) and (@toDate is null) 
   begin
      if (@creatorInit is not null)
         insert into #flattrade_view 
         select t.trade_num,
                o.order_num,
                o.order_type_code,
                o.order_strategy_name,
                t.trader_init,
                t.contr_date,
                t.creation_date,
                t.creator_init,
                t.trade_mod_init,
                t.port_num
/*****************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and 
               t.inhouse_ind = 'Y' and 
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
              t.inhouse_ind = 'Y'               
      else if (@creatorInit is null) 
         insert into #flattrade_view 
         select	t.trade_num,
                o.order_num,
                o.order_type_code,
                o.order_strategy_name,
                t.trader_init,
                t.contr_date,
                t.creation_date,
                t.creator_init,
                t.trade_mod_init,
                t.port_num
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.inhouse_ind = 'Y' and
               t.trade_num=o.trade_num and 
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
              t.inhouse_ind = 'Y'               
   end
   else if (@fromDate is null) and (@toDate is not null) 
   begin
      if (@creatorInit is not null)
         insert into #flattrade_view 
         select t.trade_num,
                o.order_num,
                o.order_type_code,
                o.order_strategy_name,
                t.trader_init,
                t.contr_date,
                t.creation_date,
                t.creator_init,
                t.trade_mod_init,
                t.port_num
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and
               t.contr_date <= @toDate and
               t.inhouse_ind = 'Y' and
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
              t.inhouse_ind = 'Y'               
      else if (@creatorInit is null)
         insert into #flattrade_view 
         select t.trade_num,
                o.order_num,
                o.order_type_code,
                o.order_strategy_name,
                t.trader_init,
                t.contr_date,
                t.creation_date,
                t.creator_init,
                t.trade_mod_init,
                t.port_num
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.contr_date <= @toDate and
               t.inhouse_ind = 'Y' and
               t.trade_num = o.trade_num and 
               t.trade_num *= e.trade_num and 
               o.order_num *= e.order_num
******************************************************************************/
         from dbo.trade t
                 inner join trade_order o
                    on t.trade_num = o.trade_num
                 left outer join trade_order_on_exch e
                    on t.trade_num = e.trade_num and 
                       o.order_num = e.order_num
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.contr_date <= @toDate and 
               t.inhouse_ind = 'Y'               
   end
   else 
   begin
      if (@creatorInit is not null)
         insert into #flattrade_view 
         select t.trade_num,
                o.order_num,
                o.order_type_code,
                o.order_strategy_name,
                t.trader_init,
                t.contr_date,
                t.creation_date,
                t.creator_init,
                t.trade_mod_init,
                t.port_num
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and
               t.contr_date >= @fromDate and 
               t.inhouse_ind = 'Y' and
               t.trade_num = o.trade_num and 
               t.trade_num *= e.trade_num and 
               o.order_num *= e.order_num
******************************************************************************/
         from dbo.trade t
                 inner join dbo.trade_order o
                    on t.trade_num = o.trade_num
                 left outer join dbo.trade_order_on_exch e
                    on t.trade_num = o.trade_num and 
                       o.order_num = e.order_num
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.creator_init in (select creator_init from #creatorInit) and 
               t.contr_date >= @fromDate and 
               t.inhouse_ind = 'Y'               
      else if (@creatorInit is null)
         insert into #flattrade_view 
         select t.trade_num,
                o.order_num,
                o.order_type_code,
                o.order_strategy_name,
                t.trader_init,
                t.contr_date,
                t.creation_date,
                t.creator_init,
                t.trade_mod_init,
                t.port_num
/******************************************************************************                
         from trade t, trade_order o, trade_order_on_exch e
         where order_type_code in (select order_type_code from #orderTypes) and 
               t.contr_date >= @fromDate and 
               t.inhouse_ind = 'Y' and
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
               t.inhouse_ind = 'Y'               
   end
return 0
GO
GRANT EXECUTE ON  [dbo].[inhouse_search1] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'inhouse_search1', NULL, NULL
GO
