SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_rev]
(
   trade_num,
   trader_init,
   trade_status_code,
   conclusion_type,
   inhouse_ind,
   acct_num,
   acct_cont_num,
   acct_short_name,
   acct_ref_num,
   port_num,
   concluded_date,
   contr_approv_type,
   contr_date,
   cr_anly_init,
   credit_term_code,
   cp_gov_contr_ind,
   contr_exch_method,
   contr_cnfrm_method,
   contr_tlx_hold_ind,
   creation_date,
   creator_init,
   trade_mod_date,
   trade_mod_init,
   invoice_cap_type,
   internal_agreement_ind,
   credit_status,
   credit_res_exp_date,
   contr_anly_init,
   contr_status_code,
   max_order_num,
   is_long_term_ind,
   special_contract_num,
   cargo_id_number,
   internal_parent_trade_num,
   copy_type,
   product_id,
   econfirm_status,
   external_trade_type,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   inv_pricing_type,
   no_of_forward_months,
   no_del_draw_price_ind,
   use_mtm,
   inventory_type,
   exch_memo_code
)
as select
   trade_num,
   trader_init,
   trade_status_code,
   conclusion_type,
   inhouse_ind,
   acct_num,
   acct_cont_num,
   acct_short_name,
   acct_ref_num,
   port_num,
   concluded_date,
   contr_approv_type,
   contr_date,
   cr_anly_init,
   credit_term_code,
   cp_gov_contr_ind,
   contr_exch_method,
   contr_cnfrm_method,
   contr_tlx_hold_ind,
   creation_date,
   creator_init,
   trade_mod_date,
   trade_mod_init,
   invoice_cap_type,
   internal_agreement_ind,
   credit_status,
   credit_res_exp_date,
   contr_anly_init,
   contr_status_code,
   max_order_num,
   is_long_term_ind,
   special_contract_num,
   cargo_id_number,
   internal_parent_trade_num,
   copy_type,
   product_id,
   econfirm_status,
   external_trade_type,
   trans_id,
   trans_id,
   resp_trans_id,
   inv_pricing_type,
   no_of_forward_months,
   no_del_draw_price_ind,
   use_mtm,
   inventory_type,
   exch_memo_code
from aud_trade                                                                                                                                            
GO
GRANT SELECT ON  [dbo].[v_trade_rev] TO [next_usr]
GO
