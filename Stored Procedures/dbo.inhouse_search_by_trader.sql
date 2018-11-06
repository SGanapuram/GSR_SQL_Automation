SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_search_by_trader]
(
   @future       varchar(20) = null,
   @option       varchar(20) = null,
   @physical     varchar(20) = null,
   @fromDate     varchar(30) = null,
   @toDate       varchar(30) = null,
   @traderInit   char(3) = null,
   @portNum      int = null,
   @creatorInit  char(3) = null,
   @deskCode     char(8) = null
)
as
set nocount on
declare @result int
declare @status int

   if @portNum = 0
      select @portNum = null

   if @future = 'NULL' or @future = 'null' or @future = ' '
      select @future = null

   if @option = 'NULL' or @option = 'null' or @option = ' '
      select @option = null

   if @physical = 'NULL' or @physical = 'null' or @physical = ' '
      select @physical = null

   if @fromDate = 'NULL' or @fromDate = 'null' or @fromDate = ' '
      select @fromDate = null

   if @toDate = 'NULL' or @toDate = 'null' or @toDate = ' '
      select @toDate = null

   if @traderInit = 'NUL' or @traderInit = 'nul' or @traderInit = ' '
      select @traderInit = null

   if @creatorInit = 'NUL' or @creatorInit = 'nul' or @creatorInit = ' '
      select @creatorInit = null

   if @deskCode = 'NULL' or @deskCode = 'null' or @deskCode = ' '
      select @deskCode = null

   if  (@future is null) and 
       (@option is null) and
       (@physical is null)
       return -600

   create table #orderTypes (order_type_code varchar(8) not null)

   if (@future is not null) 
      insert into #orderTypes values (@future)

   if (@option is not null) 
      insert into #orderTypes values (@option)

   if (@physical is not null) 
      insert into #orderTypes values (@physical)

   create table #creatorInit (creator_init char(3) null)

   if (@creatorInit is not null)
      insert into #creatorInit values (@creatorInit)

   create table #traderInit (trader_init char(3) null)
   if (@deskCode is not null)
      insert into #traderInit 
      select user_init 
      from dbo.icts_user 
      where desk_code = @deskCode

   /* if there are > 240 rows in this temp table, return, too 
      many users in this desk */
   if (@traderInit is not null)
      insert into #traderInit values (@traderInit)
   select @result = count(*) 
   from #traderInit 
   if (@result > 240) or (@result = 0)
      return -599

   create table #flattrade_view
   (
      trade_num int not null,
      order_num smallint not null,
      order_type_code varchar(8) not null,
      order_strategy_name varchar(15) null,
      trader_init char(3) null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      trade_mod_init char(3) null,
      port_num int null
   )
 
   if (@deskCode is not null) and (@result = 0)
      select @result = 0
   else 
   begin
      exec @status = dbo.inhouse_search1 @fromDate, @toDate, @creatorInit
      if (@status < 0)
	       return @status
   end

   create table #inhouse_search
   (
      trade_num int not null,
      order_num smallint not null,
      item_num smallint not null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      buy_trader_init char(3) null,
      buy_port_num int null,
      order_type_code varchar(8) null,
      p_s_ind char(1) null,
      cmdty_code varchar(8) null,
      risk_mkt_code varchar(8) null,
      title_mkt_code varchar(8) null,
      trading_prd varchar(8) null,
      item_type char(1) null,
      avg_price float null,
      total_fill_qty float null,
      put_call_ind char(1) null,
      opt_type char(1) null,
      strike_price float null,
      sell_trader_init char(3) null,
      sell_port_num int null,
      trd_prd_desc varchar(8) null,
      from_del_date varchar(2) null,
      to_del_date varchar(2) null,
      buy_sell char(1) null,
      trader_init char(3) null,
      account_num int null,
      account_name char(25) null,
      other_trdr char(3) null,
      other_acct_num int null,
      other_acct char(25) null
   )

   insert into #inhouse_search 
   select f.trade_num,
          f.order_num,
          i.item_num,
          f.contr_date,
          f.creation_date,
          f.creator_init,
          null,
          f.port_num,
          f.order_type_code,
          i.p_s_ind,
          i.cmdty_code,
          i.risk_mkt_code,
          i.title_mkt_code,
          i.trading_prd,
          i.item_type,
          i.avg_price,
          i.contr_qty,
          null,
          null,
          null,
          null,
          i.real_port_num,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null
   from #flattrade_view f, 
        dbo.trade_item i 
   where f.trade_num = i.trade_num and
         f.order_num = i.order_num

   update #inhouse_search 
   set total_fill_qty = e.total_fill_qty,
       put_call_ind = e.put_call_ind,
       opt_type = e.opt_type,
       strike_price = e.strike_price
   from #inhouse_search a, 
        dbo.trade_item_exch_opt e
   where a.trade_num = e.trade_num and
         a.order_num = e.order_num and
         a.item_num = e.item_num

   update #inhouse_search 
   set from_del_date = convert(varchar(2),datepart(dd,del_date_from)),
       to_del_date = convert(varchar(2),datepart(dd,del_date_to))
   from #inhouse_search a, 
        dbo.trade_item_wet_phy w
   where a.trade_num = w.trade_num and
         a.order_num = w.order_num and
         a.item_num = w.item_num

   update #inhouse_search 
   set buy_trader_init = owner_init
   from #inhouse_search i, 
        dbo.portfolio p
   where i.buy_port_num = p.port_num

   update #inhouse_search 
   set sell_trader_init = owner_init
   from #inhouse_search i, 
        dbo.portfolio p
   where i.sell_port_num = p.port_num
   if (@result > 0) 
   begin
      /* delete all those trades which don't have matching trader init 
         to either buy or sell side */
      delete from #inhouse_search
      where (buy_trader_init not in (select trader_init from #traderInit)) and
            (sell_trader_init not in (select trader_init from #traderInit))

      delete from #inhouse_search
      where (buy_trader_init is null) and
            (sell_trader_init not in (select trader_init from #traderInit))

      delete from #inhouse_search
      where (buy_trader_init not in (select trader_init from #traderInit)) and
            (sell_trader_init is null)

      update #inhouse_search 
      set trader_init = buy_trader_init,
          account_num = buy_port_num, 
          other_trdr = sell_trader_init,
          other_acct_num = sell_port_num, 
          buy_sell = 'P'
      where (buy_trader_init in (select trader_init from #traderInit))

      update #inhouse_search 
      set trader_init = sell_trader_init,
          account_num = sell_port_num, 
          other_trdr = buy_trader_init,
          other_acct_num = buy_port_num,
          buy_sell = 'S'
      where (sell_trader_init in (select trader_init from #traderInit))

      update #inhouse_search 
      set account_name = port_short_name
      from #inhouse_search, 
           dbo.portfolio
      where account_num = port_num

      update #inhouse_search 
      set other_acct = port_short_name
      from #inhouse_search, 
           dbo.portfolio
      where other_acct_num = port_num
   end

   /* get trading period desc now */
   update #inhouse_search 
   set trd_prd_desc = trading_prd_desc 
   from #inhouse_search q, 
        dbo.commodity_market c, 
        dbo.trading_period t 
   where q.cmdty_code = c.cmdty_code and 
         q.risk_mkt_code = c.mkt_code and 
         c.commkt_key = t.commkt_key and 
         q.trading_prd = t.trading_prd 


   /* now we have all inhouses where either the buy trader 
      or sell trader is in the list of traders that is required.  
      Duplicate every row with buy and sells switched and return */

   insert #inhouse_search 
   select 
	    trade_num,
	    order_num,
	    item_num,
	    contr_date,
	    creation_date,
	    creator_init,
	    buy_trader_init,
	    buy_port_num,
	    order_type_code,
	    'S',
	    cmdty_code,
	    risk_mkt_code,
	    title_mkt_code,
	    trading_prd,
	    item_type,
	    avg_price,
	    total_fill_qty,
	    put_call_ind,
	    opt_type,
	    strike_price,
	    sell_trader_init,
	    sell_port_num,
	    trd_prd_desc,
	    from_del_date,
	    to_del_date,
	    ' ',
	    other_trdr,
	    other_acct_num,
	    other_acct,
	    trader_init,
	    account_num,
	    account_name
   from #inhouse_search
   where buy_sell = 'P'

   insert #inhouse_search 
   select 
	    trade_num,
	    order_num,
	    item_num,
	    contr_date,
	    creation_date,
	    creator_init,
	    buy_trader_init,
	    buy_port_num,
	    order_type_code,
	    'P',
	    cmdty_code,
	    risk_mkt_code,
	    title_mkt_code,
	    trading_prd,
	    item_type,
	    avg_price,
	    total_fill_qty,
      put_call_ind,
      opt_type,
      strike_price,
      sell_trader_init,
      sell_port_num,
      trd_prd_desc,
      from_del_date,
      to_del_date,
      ' ',
      other_trdr,
      other_acct_num,
      other_acct,
	    trader_init,
	    account_num,
	    account_name
   from #inhouse_search
   where buy_sell = 'S'

   update #inhouse_search 
   set buy_sell = p_s_ind 
   where buy_sell = ' '

   select 
	    trade_num,
	    creator_init,
	    buy_sell,
	    total_fill_qty,
	    avg_price,
	    trd_prd_desc,
	    cmdty_code,
	    risk_mkt_code,
	    strike_price,
	    put_call_ind,
	    from_del_date,
	    to_del_date,
	    trader_init,
	    account_name,
	    other_trdr,
	    other_acct,
	    trader_init,
	    order_type_code
   from #inhouse_search
GO
GRANT EXECUTE ON  [dbo].[inhouse_search_by_trader] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'inhouse_search_by_trader', NULL, NULL
GO
