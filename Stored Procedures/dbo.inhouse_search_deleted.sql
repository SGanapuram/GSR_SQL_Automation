SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_search_deleted]
(
   @future varchar(20) = null,
   @option varchar(20) = null,
   @physical varchar(20) = null,
   @fromDate varchar(30) = null,
   @toDate varchar(30) = null,
   @traderInit char(3) = null,
   @portNum int = null,
   @creatorInit char(3) = null,
   @deskCode char(8) = null,
   @rptdatasw char(1) = null
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

   if @rptdatasw = 'N' or @rptdatasw = 'n' or @rptdatasw = ' '
      select @rptdatasw = null

   if (@future is null) and 
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

   select @result = count(*) from #traderInit 
   if (@result > 240)
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
      port_num int null,
      trade_trans_id int null,
      order_resp_trans int null,
      exch_resp_trans int null
   )

   if (@deskCode is not null) and (@result = 0)
      select @result = 0
   else 
   begin
      exec @status = dbo.inhouse_search1_deleted @fromDate, @toDate, @creatorInit
      if (@status < 0)
	       return @status
   end

   create table #inhouse_search
   (
      trade_num int not null,
      order_num smallint not null,
      item_num smallint not null,
      trader_init char(3) null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      buy_trader_init char(3) null,
      buy_port_num int null,
      order_type_code varchar(8) null,
      z_trade_ind char(1) null,
      post_ind char(1) null,
      trade_mod_init char(3) null,
      p_s_ind char(1) null,
      cmdty_code varchar(8) null,
      risk_mkt_code varchar(8) null,
      title_mkt_code varchar(8) null,
      trading_prd varchar(8) null,
      contr_qty float null,
      contr_qty_uom_code char(4) null,
      item_type char(1) null,
      avg_price float null,
      price_curr_code varchar(8) null,
      price_uom_code varchar(4) null,
      idms_acct_alloc varchar(8) null,
      total_fill_qty float null,
      avg_fill_price float null,
      put_call_ind char(1) null,
      opt_type char(1) null,
      strike_price float null,
      strike_price_uom_code varchar(4) null,
      strike_price_curr_code varchar(8) null,
      sell_trader_init char(3) null,
      sell_port_num int null,
      trd_prd_desc varchar(8) null,
      from_del_date varchar(2) null,
      to_del_date varchar(2) null,
      trade_trans_id int null
   )

   insert into #inhouse_search 
   select f.trade_num,
          f.order_num,
          i.item_num,
          f.trader_init,
          f.contr_date,
          f.creation_date,
          f.creator_init,
          null,
          f.port_num,
          f.order_type_code,
          substring(order_strategy_name,14,1),
          substring(order_strategy_name,15,1),
          f.trade_mod_init,
          i.p_s_ind,
          i.cmdty_code,
          i.risk_mkt_code,
          i.title_mkt_code,
          i.trading_prd,
          i.contr_qty,
          i.contr_qty_uom_code,
          i.item_type,
          i.avg_price,
          i.price_curr_code,
          i.price_uom_code,
          i.idms_acct_alloc,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          i.real_port_num,
          null,
          null,
          null,
          f.trade_trans_id
   from #flattrade_view f, 
        dbo.aud_trade_item i 
   where f.trade_num = i.trade_num and
         f.order_num = i.order_num and
         i.resp_trans_id = f.trade_trans_id

   if (@portNum is not null) 
   begin
      /* delete all those trades which don't have matching portfolio 
         to either buy or sell side */
      delete from #inhouse_search
      where (buy_port_num != @portNum) and
            (sell_port_num != @portNum)

      delete from #inhouse_search
      where (buy_port_num is null) and
            (sell_port_num != @portNum)

      delete from #inhouse_search
      where (buy_port_num != @portNum) and
            (sell_port_num is null)
   end

   update #inhouse_search 
   set total_fill_qty = f.fill_qty,
       avg_fill_price = f.fill_price
   from #inhouse_search a, 
        dbo.aud_trade_item_fill f
   where a.trade_num = f.trade_num and
         a.order_num = f.order_num and
         a.item_num = f.item_num and
         f.resp_trans_id = trade_trans_id

   update #inhouse_search 
   set put_call_ind = e.put_call_ind,
       opt_type = e.opt_type,
       strike_price = e.strike_price,
       strike_price_uom_code = e.strike_price_uom_code,
       strike_price_curr_code = e.strike_price_curr_code
   from #inhouse_search a, 
        dbo.aud_trade_item_exch_opt e
   where a.trade_num = e.trade_num and
         a.order_num = e.order_num and
         a.item_num = e.item_num and
         e.resp_trans_id = trade_trans_id

   update #inhouse_search 
   set from_del_date = convert(varchar(2),datepart(dd,del_date_from)),
       to_del_date = convert(varchar(2),datepart(dd,del_date_to))
   from #inhouse_search a, 
        dbo.aud_trade_item_wet_phy w
   where a.trade_num = w.trade_num and
         a.order_num = w.order_num and
         a.item_num = w.item_num and
         w.resp_trans_id = trade_trans_id

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

   if @rptdatasw = 'Y' 
   begin
      alter table #inhouse_search 
	        add buy_port_short_name char(25) null,
              sell_port_short_name char(25) null
      exec dbo.inhouse_search_desc
   end
   else 
   begin
      select a.*
      from #inhouse_search a	
      order by a.creation_date, a.item_num
   end
GO
GRANT EXECUTE ON  [dbo].[inhouse_search_deleted] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'inhouse_search_deleted', NULL, NULL
GO
