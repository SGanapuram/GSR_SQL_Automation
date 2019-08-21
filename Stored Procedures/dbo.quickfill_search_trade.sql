SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_search_trade]
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
      trade_num              int         not null,
      order_num              smallint    not null,
      order_type_code        varchar(8)  not null,
      trader_init            char(3)     null,
      trade_status_code      varchar(8)  null,
      contr_date             datetime    null,
      creation_date          datetime    null,
      creator_init           char(3)     null,
      order_price            float       null,
      order_price_curr_code  char(8)     null,
      order_points           float       null,
      order_instr_code       varchar(8)  null,
      order_strategy_name    varchar(15) null,
      trade_trans_id         bigint         null,
      order_trans_id         bigint         null,
      order_on_exch_trans_id bigint         null
   )
 
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
      o.order_strategy_name,
      t.trans_id,
      o.trans_id,
      e.trans_id
   from dbo.trade t, 
        dbo.trade_order o, 
        dbo.trade_order_on_exch e
   where t.trade_num = @tradeNum and
	       o.order_num = @orderNum and 
	       o.trade_num = @tradeNum and 
	       e.trade_num = @tradeNum and
	       e.order_num = @orderNum

   create table #quickfill_search 
   (
      trade_num int not null,
      order_num smallint not null,
      item_num smallint not null,
      trader_init char(3) null,
      trade_status_code varchar(8) null,
      contr_date datetime null,
      creation_date datetime null,
      creator_init char(3) null,
      order_type_code varchar(8) null,
      order_price float null,
      order_price_curr_code char(8) null,
      order_points float null,
      order_instr_code varchar(8) null,
      order_strategy_name varchar(15) null,
      item_status_code varchar(8) null,
      p_s_ind char(1) null,
      booking_comp_num int null,
      cmdty_code varchar(8) null,
      risk_mkt_code varchar(8) null,
      title_mkt_code varchar(8) null,
      trading_prd varchar(8) null,
      contr_qty float null,
      contr_qty_uom_code char(4) null,
      item_type char(1) null,
      total_priced_qty float null,
      priced_qty_uom_code varchar(4) null,
      avg_price float null,
      price_curr_code varchar(8) null,
      price_uom_code varchar(4) null,
      idms_bb_ref_num varchar(10) null,
      idms_acct_alloc varchar(8) null,
      brkr_num int null,
      fut_trader_init char(3) null,
      settlement_type char(1) null,
      fut_price float null,
      fut_price_curr_code char(8) null,
      total_fill_qty float null,
      avg_fill_price float null,
      clr_brkr_num int null,
      put_call_ind char(1) null,
      opt_type char(1) null,
      strike_price float null,
      strike_price_uom_code varchar(4) null,
      strike_price_curr_code varchar(8) null,
      real_port_num int null,
      is_hedge_ind char(1) null,
      trade_trans_id bigint  null,
      order_trans_id bigint null,
      order_on_exch_trans_id bigint null,
      item_trans_id bigint null,
      fut_trans_id bigint null,
      opt_trans_id bigint null,
      trd_prd_desc varchar(8) null,
      cmnt_num int null,
      tiny_cmnt varchar(15) null,
      trade_sync_trans_id bigint null
   )

   insert into #quickfill_search 
   select 
	    f.trade_num,
	    f.order_num,
	    i.item_num,
	    f.trader_init,
	    f.trade_status_code,
	    f.contr_date,
	    f.creation_date,
	    f.creator_init,
	    f.order_type_code,
	    f.order_price,
	    f.order_price_curr_code,
	    f.order_points,
	    f.order_instr_code,
	    f.order_strategy_name,
	    i.item_status_code,
	    i.p_s_ind,
	    i.booking_comp_num,
	    i.cmdty_code,
	    i.risk_mkt_code,
	    i.title_mkt_code,
	    i.trading_prd,
	    i.contr_qty,
	    i.contr_qty_uom_code,
	    i.item_type,
	    i.total_priced_qty,
	    i.priced_qty_uom_code,
	    i.avg_price,
	    i.price_curr_code,
	    i.price_uom_code,
	    i.idms_bb_ref_num,
	    i.idms_acct_alloc,
	    i.brkr_num,
	    i.fut_trader_init,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    i.real_port_num,
	    i.hedge_pos_ind,
	    f.trade_trans_id,
	    f.order_trans_id,
	    f.order_on_exch_trans_id,
	    i.trans_id,
	    null,
	    null,
	    null,
	    i.cmnt_num,
    	null,
	    null	
   from #flattrade_view f, 
        dbo.trade_item i 
   where f.trade_num = i.trade_num and
         f.order_num = i.order_num 

   if (@tradeType = 'FUTURE') 
   begin
      update #quickfill_search 
      set settlement_type = u.settlement_type,
	        fut_price = u.fut_price,
          fut_price_curr_code = u.fut_price_curr_code,
          total_fill_qty = u.total_fill_qty,
          avg_fill_price = u.avg_fill_price,
	        clr_brkr_num = u.clr_brkr_num,
	        fut_trans_id = u.trans_id
      from dbo.trade_item_fut u	
      where #quickfill_search.trade_num = u.trade_num and
            #quickfill_search.order_num = u.order_num and
            #quickfill_search.item_num = u.item_num
   end
   else 
   begin
      update #quickfill_search 
      set total_fill_qty = e.total_fill_qty,
          avg_fill_price = e.avg_fill_price,
	        clr_brkr_num = e.clr_brkr_num,
	        put_call_ind = e.put_call_ind,
	        opt_type = e.opt_type,
	        strike_price = e.strike_price,
	        strike_price_uom_code = e.strike_price_uom_code,
	        strike_price_curr_code = e.strike_price_curr_code,
          opt_trans_id = e.trans_id
      from dbo.trade_item_exch_opt e	
      where #quickfill_search.trade_num = e.trade_num and
            #quickfill_search.order_num = e.order_num and
            #quickfill_search.item_num = e.item_num
   end

   update #quickfill_search 
   set trade_sync_trans_id = trans_id 
   from dbo.trade_sync s 
   where s.trade_num = @tradeNum and 
         #quickfill_search.trade_num = s.trade_num

   /* *** get trading period desc now *** */
   update #quickfill_search 
   set trd_prd_desc = trading_prd_desc 
   from dbo.commodity_market c, 
        dbo.trading_period t 
   where #quickfill_search.cmdty_code = c.cmdty_code and 
         #quickfill_search.risk_mkt_code = c.mkt_code and 
         c.commkt_key = t.commkt_key and 
         #quickfill_search.trading_prd = t.trading_prd 

   /* * check if we need to fetch comments * */
   select @cmntCount = count(*) 
   from #quickfill_search 
   where cmnt_num is not null

   if (@cmntCount > 0) 
   begin
      update #quickfill_search 
      set tiny_cmnt = p.tiny_cmnt 
      from dbo.pei_comment p 
      where #quickfill_search.cmnt_num is not null and 
            #quickfill_search.cmnt_num = p.cmnt_num
   end

   select 
      a.*,
      l.item_fill_num,
      l.fill_qty,
      l.fill_qty_uom_code,
      l.fill_price,
      l.fill_price_curr_code,
      l.fill_price_uom_code,
      l.fill_date,
      l.bsi_fill_num,
      fill_trans_id = l.trans_id
/******************************************************************************      
   from #quickfill_search a, trade_item_fill l
   where a.trade_num *= l.trade_num and
         a.order_num *= l.order_num and
         a.item_num  *= l.item_num
******************************************************************************/
   from #quickfill_search a
           left outer join dbo.trade_item_fill l
              on a.trade_num = l.trade_num and 
                 a.order_num = l.order_num and 
                 a.item_num = l.item_num         
GO
GRANT EXECUTE ON  [dbo].[quickfill_search_trade] TO [next_usr]
GO
