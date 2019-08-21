SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_ti_rs]
(
   trade_num,
   order_num,
   item_num,
   item_status_code,
   p_s_ind,
   booking_comp_num,
   gtc_code,
   cmdty_code,
   risk_mkt_code,
   title_mkt_code,
   trading_prd,
   contr_qty,
   contr_qty_uom_code,
   contr_qty_periodicity,
   accum_periodicity,
   uom_conv_rate,
   item_type,
   formula_ind,
   total_priced_qty,
   priced_qty_uom_code,
   avg_price,
   price_curr_code,
   price_uom_code,
   idms_bb_ref_num,
   idms_contr_num,
   idms_profit_center,
   idms_acct_alloc,
   cmnt_num,
   brkr_num,
   brkr_cont_num,
   brkr_comm_amt,
   brkr_comm_curr_code,
   brkr_comm_uom_code,
   brkr_ref_num,
   fut_trader_init,
   parent_item_num,
   real_port_num,
   amend_num,
   amend_creation_date,
   amend_effect_start_date,
   amend_effect_end_date,
   summary_item_num,
   pooling_type,
   pooling_port_num,
   pooling_port_ind,
   total_sch_qty,
   sch_qty_uom_code,
   open_qty,
   open_qty_uom_code,
   mtm_pl,
   mtm_pl_curr_code,
   mtm_pl_as_of_date,
   strip_item_status,
   estimate_ind,
   billing_type,
   sched_status,
   hedge_rate,
   hedge_curr_code,
   hedge_multi_div_ind,
   recap_item_num,
   hedge_pos_ind,
   addl_cost_sum,
   contr_mtm_pl,
   max_accum_num,
   formula_declar_date,
   purchasing_group,
   origin_country_code,
   load_port_loc_code,
   disch_port_loc_code,
   excp_addns_code,
   internal_parent_trade_num,
   internal_parent_order_num,
   internal_parent_item_num,
   trade_modified_ind,
   item_confirm_ind,
   finance_bank_num,
   agreement_num,
   active_status_ind,
   market_value,
   includes_excise_tax_ind,  
   includes_fuel_tax_ind,
   total_committed_qty,
   committed_qty_uom_code,
   is_cleared_ind,
   clr_service_num,
   exch_brkr_num,
   rin_ind,  
   is_lc_assigned,
   is_rc_assigned,
   b2b_trade_item,
   use_mkt_formula_for_pl,
   sap_order_num,
   calendar_code,
   real_quote_period_id,
   quote_id,
   leg_id,
   flat_amt,      
   trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name
)
as
select
   ti.trade_num,
   ti.order_num,
   ti.item_num,
   ti.item_status_code,
   ti.p_s_ind,
   ti.booking_comp_num,
   ti.gtc_code,
   ti.cmdty_code,
   ti.risk_mkt_code,
   ti.title_mkt_code,
   ti.trading_prd,
   ti.contr_qty,
   ti.contr_qty_uom_code,
   ti.contr_qty_periodicity,
   ti.accum_periodicity,
   ti.uom_conv_rate,
   ti.item_type,
   ti.formula_ind,
   ti.total_priced_qty,
   ti.priced_qty_uom_code,
   ti.avg_price,
   ti.price_curr_code,
   ti.price_uom_code,
   ti.idms_bb_ref_num,
   ti.idms_contr_num,
   ti.idms_profit_center,
   ti.idms_acct_alloc,
   ti.cmnt_num,
   ti.brkr_num,
   ti.brkr_cont_num,
   ti.brkr_comm_amt,
   ti.brkr_comm_curr_code,
   ti.brkr_comm_uom_code,
   ti.brkr_ref_num,
   ti.fut_trader_init,
   ti.parent_item_num,
   ti.real_port_num,
   ti.amend_num,
   ti.amend_creation_date,
   ti.amend_effect_start_date,
   ti.amend_effect_end_date,
   ti.summary_item_num,
   ti.pooling_type,
   ti.pooling_port_num,
   ti.pooling_port_ind,
   ti.total_sch_qty,
   ti.sch_qty_uom_code,
   ti.open_qty,
   ti.open_qty_uom_code,
   ti.mtm_pl,
   ti.mtm_pl_curr_code,
   ti.mtm_pl_as_of_date,
   ti.strip_item_status,
   ti.estimate_ind,
   ti.billing_type,
   ti.sched_status,
   ti.hedge_rate,
   ti.hedge_curr_code,
   ti.hedge_multi_div_ind,
   ti.recap_item_num,
   ti.hedge_pos_ind,
   ti.addl_cost_sum,
   ti.contr_mtm_pl,
   ti.max_accum_num,
   ti.formula_declar_date,
   ti.purchasing_group,
   ti.origin_country_code,
   ti.load_port_loc_code,
   ti.disch_port_loc_code,
   ti.excp_addns_code,
   ti.internal_parent_trade_num,
   ti.internal_parent_order_num,
   ti.internal_parent_item_num,
   ti.trade_modified_ind,
   ti.item_confirm_ind,
   ti.finance_bank_num,
   ti.agreement_num,
   ti.active_status_ind,
   ti.market_value,
   ti.includes_excise_tax_ind,  
   ti.includes_fuel_tax_ind,
   ti.total_committed_qty,
   ti.committed_qty_uom_code,
   ti.is_cleared_ind,
   ti.clr_service_num,
   ti.exch_brkr_num,
   ti.rin_ind,  
   ti.is_lc_assigned,
   ti.is_rc_assigned,
   ti.b2b_trade_item,
   ti.use_mkt_formula_for_pl,
   ti.sap_order_num,
   ti.calendar_code,
   ti.real_quote_period_id,
   ti.quote_id,
   ti.leg_id,
   ti.flat_amt,   
   ti.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name
from dbo.aud_trade_item ti
        left outer join dbo.icts_transaction it
           on ti.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ti_rs] TO [next_usr]
GO