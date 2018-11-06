SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_trade_all_rs]
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
   trans_id,
   resp_trans_id,
   internal_parent_trade_num,
   copy_type,
   product_id,
   econfirm_status,
   external_trade_type,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.trade_num,
   maintb.trader_init,
   maintb.trade_status_code,
   maintb.conclusion_type,
   maintb.inhouse_ind,
   maintb.acct_num,
   maintb.acct_cont_num,
   maintb.acct_short_name,
   maintb.acct_ref_num,
   maintb.port_num,
   maintb.concluded_date,
   maintb.contr_approv_type,
   maintb.contr_date,
   maintb.cr_anly_init,
   maintb.credit_term_code,
   maintb.cp_gov_contr_ind,
   maintb.contr_exch_method,
   maintb.contr_cnfrm_method,
   maintb.contr_tlx_hold_ind,
   maintb.creation_date,
   maintb.creator_init,
   maintb.trade_mod_date,
   maintb.trade_mod_init,
   maintb.invoice_cap_type,
   maintb.internal_agreement_ind,
   maintb.credit_status,
   maintb.credit_res_exp_date,
   maintb.contr_anly_init,
   maintb.contr_status_code,
   maintb.max_order_num,
   maintb.is_long_term_ind,
   maintb.special_contract_num,
   maintb.cargo_id_number,
   maintb.trans_id,
   null,
   maintb.internal_parent_trade_num,
   maintb.copy_type,
   maintb.product_id,
   maintb.econfirm_status,
   maintb.external_trade_type,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.trade_num,
   audtb.trader_init,
   audtb.trade_status_code,
   audtb.conclusion_type,
   audtb.inhouse_ind,
   audtb.acct_num,
   audtb.acct_cont_num,
   audtb.acct_short_name,
   audtb.acct_ref_num,
   audtb.port_num,
   audtb.concluded_date,
   audtb.contr_approv_type,
   audtb.contr_date,
   audtb.cr_anly_init,
   audtb.credit_term_code,
   audtb.cp_gov_contr_ind,
   audtb.contr_exch_method,
   audtb.contr_cnfrm_method,
   audtb.contr_tlx_hold_ind,
   audtb.creation_date,
   audtb.creator_init,
   audtb.trade_mod_date,
   audtb.trade_mod_init,
   audtb.invoice_cap_type,
   audtb.internal_agreement_ind,
   audtb.credit_status,
   audtb.credit_res_exp_date,
   audtb.contr_anly_init,
   audtb.contr_status_code,
   audtb.max_order_num,
   audtb.is_long_term_ind,
   audtb.special_contract_num,
   audtb.cargo_id_number,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.internal_parent_trade_num,
   audtb.copy_type,
   audtb.product_id,
   audtb.econfirm_status,
   audtb.external_trade_type,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_trade_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_trade_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_all_rs', NULL, NULL
GO