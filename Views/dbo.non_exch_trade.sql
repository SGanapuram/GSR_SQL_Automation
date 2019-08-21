SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[non_exch_trade]
(
	 trade_num,			
	 trader_init,		
	 trade_status_code,	
	 conclusion_type,
	 inhouse_ind,
	 acct_ref_num,
	 contr_num,
	 contr_volume,
	 acct_num,			
	 contr_date,
	 creation_date,
	 creator_init,		
	 credit_res_exp_date,
	 credit_status,
	 trade_mod_date,
	 trade_mod_init,		
	 order_num,			
	 order_type_code,	
	 order_status_code,	
	 parent_order_ind,
	 parent_order_num,	
	 order_strategy_num,
	 order_strategy_name,
	 order_strip_num,
   term_evergreen_ind,
	 item_num,
	 item_status_code,	
	 p_s_ind,
	 booking_comp_num,	
	 cmdty_code,			
	 risk_mkt_code,		
	 title_mkt_code,		
	 real_port_num,
	 contr_qty,
	 formula_ind,
	 total_priced_qty,
	 brkr_num,			
	 brkr_cont_num,
	 brkr_comm_amt,
	 brkr_comm_curr_code,
	 brkr_comm_uom_code,
	 brkr_ref_num,
	 idms_profit_center,
	 idms_acct_alloc,
	 trading_prd,
	 contr_exch_method,
	 contr_cnfrm_method,
	 contr_anly_init,
	 contr_status_code
)
as	
select
   t.trade_num,
   trader_init,
   trade_status_code,
   conclusion_type,
   inhouse_ind,
   t.acct_ref_num,
   t.trade_num,
   i.contr_qty,
   acct_num,
   contr_date,
   t.creation_date,
   t.creator_init,
   t.credit_res_exp_date,
   t.credit_status,
   t.trade_mod_date,
   t.trade_mod_init,
   o.order_num		,
   order_type_code,
   order_status_code,
   parent_order_ind,
   parent_order_num,
   order_strategy_num,
   order_strategy_name,
   order_strip_num,
   term_evergreen_ind,
   i.item_num,
   item_status_code,
   p_s_ind,
   booking_comp_num,
   cmdty_code,
   risk_mkt_code,
   title_mkt_code,
   i.real_port_num,
   i.contr_qty,
   formula_ind,
   i.total_priced_qty,
   brkr_num,
   brkr_cont_num,
   brkr_comm_amt,
   brkr_comm_curr_code,
   brkr_comm_uom_code,
   brkr_ref_num,
   idms_profit_center,
   idms_acct_alloc,
   i.trading_prd,
   t.contr_exch_method,
   t.contr_cnfrm_method,
   t.contr_anly_init,
   t.contr_status_code
from dbo.trade t,
	   dbo.trade_order o,
	   dbo.trade_item i
where t.trade_num = o.trade_num	and
      o.trade_num =	i.trade_num	and
      o.order_num =	i.order_num	and
      t.trade_num =	i.trade_num
GO
GRANT SELECT ON  [dbo].[non_exch_trade] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[non_exch_trade] TO [next_usr]
GO