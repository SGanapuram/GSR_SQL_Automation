SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_search_desc]
as 
set nocount on
/* This stored procedure uses the following temporary tables:
     create table #quickfill_search 
     (
        trade_num                  int not null,
        order_num                  smallint not null,
        item_num                   smallint not null,
        trader_init                char(3) null,
        trade_status_code          varchar(8) null,
        contr_date                 datetime null,
        creation_date              datetime null,
        creator_init               char(3) null,
        order_type_code            varchar(8) null,
        order_price                float null,
        order_price_curr_code      char(8) null,
        order_points               float null,
        order_instr_code           varchar(8) null,
        order_strategy_name        varchar(15) null,
        item_status_code           varchar(8) null,
        p_s_ind                    char(1) null,
        booking_comp_num           int null,
        cmdty_code                 varchar(8) null,
        risk_mkt_code              varchar(8) null,
        title_mkt_code             varchar(8) null,
        trading_prd                varchar(8) null,
        contr_qty                  float null,
        contr_qty_uom_code         char(4) null,
        item_type                  char(1) null,
        total_priced_qty           float null,
        priced_qty_uom_code        varchar(4) null,
        avg_price                  float null,
        price_curr_code            varchar(8) null,
        price_uom_code             varchar(4) null,
        idms_bb_ref_num            varchar(10) null,
        idms_acct_alloc            varchar(8) null,
        brkr_num                   int null,
        fut_trader_init            char(3) null,
        settlement_type            char(1) null,
        fut_price                  float null,
        fut_price_curr_code        char(8) null,
        total_fill_qty             float null,
        avg_fill_price             float null,
        clr_brkr_num               int null,
        put_call_ind               char(1) null,
        opt_type                   char(1) null,
        strike_price               float null,
        strike_price_uom_code      varchar(4) null,
        strike_price_curr_code     varchar(8) null,
        real_port_num              int null,
        trd_prd_desc               varchar(8) null,
        cmnt_num                   int null
    )

   alter table #quickfill_search  
      add f_broker char(13) null,
          c_broker char(13) null,
	        tiny_cmnt char(15) null

*/

declare @cmntCount int

   update #quickfill_search 
   set f_broker = acct_short_name 
   from dbo.account 
   where brkr_num = acct_num

   update #quickfill_search 
   set c_broker = acct_short_name 
   from dbo.account 
   where clr_brkr_num = acct_num

   select @cmntCount = count(*) 
   from #quickfill_search 
   where cmnt_num != null
   if (@cmntCount > 0) 
   begin
      /* if there is a comment num, set tiny_cmnt ****/
      update #quickfill_search 
      set tiny_cmnt = p.tiny_cmnt 
      from dbo.pei_comment p 
      where #quickfill_search.cmnt_num is not null and 
            #quickfill_search.cmnt_num = p.cmnt_num
   end

   select 
	    a.trade_num,
	    a.order_num,
	    a.item_num,
	    a.trader_init,
	    a.trade_status_code,
	    a.contr_date,
	    a.creation_date,
	    a.creator_init,
	    a.order_type_code,
	    a.order_price,
	    a.order_price_curr_code,
	    a.order_points float,
	    a.order_instr_code,
	    a.order_strategy_name,
	    a.item_status_code,
	    a.p_s_ind,
      a.booking_comp_num,
      a.cmdty_code,
      a.risk_mkt_code,
	    a.title_mkt_code,
	    a.trading_prd,
	    a.contr_qty,
	    a.contr_qty_uom_code,
	    a.item_type,
	    a.total_priced_qty,
	    a.priced_qty_uom_code,
	    a.avg_price,
	    a.price_curr_code,
	    a.price_uom_code,
	    a.idms_bb_ref_num,
	    a.idms_acct_alloc,
	    a.brkr_num,
	    a.fut_trader_init,
	    a.settlement_type,
	    a.fut_price,
	    a.fut_price_curr_code,
	    a.total_fill_qty,
	    a.avg_fill_price,
	    a.clr_brkr_num,
	    a.put_call_ind,
	    a.opt_type,
	    a.strike_price,
	    a.strike_price_uom_code,
	    a.strike_price_curr_code,
	    a.real_port_num,
	    a.f_broker,
	    a.c_broker,
	    a.trd_prd_desc,
	    l.item_fill_num,
	    l.fill_qty,
	    l.fill_qty_uom_code,
	    l.fill_price,
	    l.fill_price_curr_code,
	    l.fill_price_uom_code,
	    l.fill_date,
	    l.bsi_fill_num,
	    a.tiny_cmnt	
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
   order by creation_date, a.item_num, item_fill_num 
return 0         
GO
GRANT EXECUTE ON  [dbo].[quickfill_search_desc] TO [next_usr]
GO
