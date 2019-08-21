SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_search_trade]
(
   @tradeNum int = null,
   @orderNum int = null
)
as
set nocount on
declare @tradeType char(8),
        @result    int,
        @cmntCount int

   select @tradeType = order_type_code 
   from dbo.trade_order 
   where trade_num = @tradeNum

   create table #flattrade_view 
   (
      trade_num           int not null,
      order_num           smallint not null,
      order_type_code     varchar(8) not null,
      order_strategy_name varchar(15) null,
      trader_init         char(3) null,
      contr_date          datetime null,
      creation_date       datetime null,
      creator_init        char(3) null,
      buy_trader_init     char(3) null,
      port_num            int null,
      trade_mod_date      datetime null,
      trade_mod_init      char(3) null,
      trans_id_trade      bigint null,
      order_trans_id      bigint null
   )
 
   insert into #flattrade_view 
   select t.trade_num,
          o.order_num,
          o.order_type_code,
          o.order_strategy_name,
          t.trader_init,
          t.contr_date,
          t.creation_date,
          t.creator_init,
          null,
          t.port_num,
          t.trade_mod_date,
          t.trade_mod_init,
          t.trans_id,
          o.trans_id
   from dbo.trade t, 
        dbo.trade_order o
   where t.trade_num = @tradeNum and
	       o.order_num = @orderNum and 
	       o.trade_num = @tradeNum

   update #flattrade_view 
   set buy_trader_init = owner_init
   from dbo.portfolio p
   where #flattrade_view.port_num = p.port_num

   create table #inhouse_search 
   (
      trade_num int not null,
      order_num smallint not null,
      item_num smallint not null,
      trader_init char(3) null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      order_type_code varchar(8) null,
      z_trade_ind char(1) null,
      buy_trader_init char(3) null,
      buy_port_num int null,
      is_hedge_ind_trade char(1) null,
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
      put_call_ind char(1) null,
      opt_type char(1) null,
      strike_price float null,
      strike_price_uom_code varchar(4) null,
      strike_price_curr_code varchar(8) null,
      sell_trader_init char(3) null,
      sell_port_num int null,
      is_hedge_ind_item char(1) null,
      trade_mod_date varchar(30) null,
      trade_mod_init char(3) null,
      trans_id_trade bigint null,
      order_trans_id bigint null,
      item_trans_id bigint null,
      fut_trans_id bigint null,
      opt_trans_id bigint null,
      phy_trans_id bigint null,
      trd_prd_desc varchar(8) null,
      cmnt_num int null,
      tiny_cmnt varchar(15) null,
      from_del_date varchar(2) null,
      to_del_date varchar(2) null,
      sync_trans_id bigint null
   )

  insert into #inhouse_search 
  select 
	   f.trade_num,
	   f.order_num,
	   i.item_num,
	   f.trader_init,
	   f.contr_date,
	   f.creation_date,
	   f.creator_init,
	   f.order_type_code,
	   substring(f.order_strategy_name,14,1),
	   f.buy_trader_init,
	   f.port_num,
	   i.hedge_pos_ind,
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
	   i.real_port_num,
	   i.hedge_pos_ind,
	   convert(varchar(30),f.trade_mod_date,109),
	   f.trade_mod_init,
	   f.trans_id_trade,
	   f.order_trans_id,
	   i.trans_id,
	   null,
	   null,
	   null,
	   null,
	   i.cmnt_num,
	   null,
	   null,
	   null,
	   null
   from #flattrade_view f, 
        dbo.trade_item i 
   where f.trade_num = i.trade_num and
	       f.order_num = i.order_num 

   update #inhouse_search 
   set sell_trader_init = owner_init 
   from dbo.portfolio p
   where #inhouse_search.sell_port_num = p.port_num

   update #inhouse_search 
   set sync_trans_id = trans_id 
   from dbo.trade_sync s
   where s.trade_num = @tradeNum

   if (@tradeType = 'FUTURE') 
   begin
      update #inhouse_search 
      set fut_trans_id = u.trans_id
      from dbo.trade_item_fut u
      where #inhouse_search.trade_num = u.trade_num and
	          #inhouse_search.order_num = u.order_num and
	          #inhouse_search.item_num = u.item_num
   end
   else 
   if (@tradeType = 'EXCHGOPT') 
   begin
      update #inhouse_search 
      set put_call_ind = e.put_call_ind,
          opt_type = e.opt_type,
          strike_price = e.strike_price,
          strike_price_uom_code = e.strike_price_uom_code,
          strike_price_curr_code = e.strike_price_curr_code,
          opt_trans_id = e.trans_id
	    from dbo.trade_item_exch_opt e
	    where #inhouse_search.trade_num = e.trade_num and
	          #inhouse_search.order_num = e.order_num and
	         #inhouse_search.item_num = e.item_num
   end
   else if (@tradeType = 'PHYSICAL') 
   begin
      update #inhouse_search 
      set from_del_date = convert(varchar(2),datepart(dd,del_date_from)),
          to_del_date = convert(varchar(2),datepart(dd,del_date_to)),
          phy_trans_id = w.trans_id
      from dbo.trade_item_wet_phy w
      where #inhouse_search.trade_num = w.trade_num and
            #inhouse_search.order_num = w.order_num and
            #inhouse_search.item_num = w.item_num
   end

   /* get trading period desc now */
   update #inhouse_search 
   set trd_prd_desc = trading_prd_desc 
   from dbo.commodity_market c, 
        dbo.trading_period t 
   where #inhouse_search.cmdty_code = c.cmdty_code and 
         #inhouse_search.risk_mkt_code = c.mkt_code and 
         c.commkt_key = t.commkt_key and 
         #inhouse_search.trading_prd = t.trading_prd 

   /** check if we need to fetch comments **/
   select @cmntCount = count(*) 
   from #inhouse_search 
   where cmnt_num is not null

   if (@cmntCount > 0) 
   begin
      update #inhouse_search 
      set tiny_cmnt = p.tiny_cmnt 
      from dbo.pei_comment p 
      where #inhouse_search.cmnt_num is not null and 
            #inhouse_search.cmnt_num = p.cmnt_num
   end

   select a.*, 
          fill_trans_id = f.trans_id 
/******************************************************************************   
   from #inhouse_search a, 
        dbo.trade_item_fill f
   where a.trade_num *= f.trade_num and
         a.order_num *= f.order_num and
         a.item_num  *= f.item_num
******************************************************************************/
    from #inhouse_search a
            left outer join trade_item_fill f
               on a.trade_num = f.trade_num and 
                  a.order_num = f.order_num and 
                  a.item_num = f.item_num         
GO
GRANT EXECUTE ON  [dbo].[inhouse_search_trade] TO [next_usr]
GO
