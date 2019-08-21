SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_cost_all_rs]
(
   cost_num,
   cost_code,
   cost_status,
   cost_prim_sec_ind,
   cost_est_final_ind,
   cost_pay_rec_ind,
   cost_type_code,
   bus_cost_type_num,
   bus_cost_state_num,
   bus_cost_fate_num,
   bus_cost_fate_mod_date,
   bus_cost_fate_mod_init,
   cost_owner_code,
   cost_owner_key1,
   cost_owner_key2,
   cost_owner_key3,
   cost_owner_key4,
   cost_owner_key5,
   cost_owner_key6,
   cost_owner_key7,
   cost_owner_key8,
   parent_cost_num,
   port_num,
   pos_group_num,
   acct_num,
   cost_qty,
   cost_qty_uom_code,
   cost_qty_est_actual_ind,
   cost_unit_price,
   cost_price_curr_code,
   cost_price_uom_code,
   cost_price_est_actual_ind,
   cost_amt,
   cost_amt_type,
   cost_vouchered_amt,
   cost_drawn_bal_amt,
   pay_method_code,
   pay_term_code,
   cost_pay_days,
   credit_term_code,
   cost_book_comp_num,
   cost_book_comp_short_name,
   cost_book_prd_date,
   cost_book_curr_code,
   cost_book_exch_rate,
   cost_xrate_conv_ind,
   creation_date,
   creator_init,
   cost_eff_date,
   cost_due_date,
   cost_due_date_mod_date,
   cost_due_date_mod_init,
   cost_approval_date,
   cost_approval_init,
   cost_gl_acct_cr_code,
   cost_gl_acct_dr_code,
   cost_gl_acct_mod_date,
   cost_gl_acct_mod_init,
   cost_gl_book_type_code,
   cost_gl_book_date,
   cost_gl_book_init,
   cost_gl_offset_acct_code,
   cost_short_cmnt,
   cmnt_num,
   cost_accrual_ind,
   cost_price_mod_date,
   cost_price_mod_init,
   cost_partial_ind,
   first_accrued_date,
   cost_period_ind,
   cost_pl_code,
   cost_paid_date,
   cost_credit_ind,
   cost_center_code_debt,
   cost_center_code_credit,
   cost_send_id,
   vc_acct_num,
   cash_date,
   po_number,
   eff_date_override_trans_id,
   finance_bank_num,
   tax_status_code,
   external_ref_key,
   cost_rate_oid,
   template_cost_num,
   internal_cost_ind,
   assay_final_ind,
   qty_type,
   resp_trans_id,
   trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence,
   user_mod_date,
   summary_cost_num
)
as
select
   cost.cost_num,
   cost.cost_code,
   cost.cost_status,
   cost.cost_prim_sec_ind,
   cost.cost_est_final_ind,
   cost.cost_pay_rec_ind,
   cost.cost_type_code,
   cost.bus_cost_type_num,
   cost.bus_cost_state_num,
   cost.bus_cost_fate_num,
   cost.bus_cost_fate_mod_date,
   cost.bus_cost_fate_mod_init,
   cost.cost_owner_code,
   cost.cost_owner_key1,
   cost.cost_owner_key2,
   cost.cost_owner_key3,
   cost.cost_owner_key4,
   cost.cost_owner_key5,
   cost.cost_owner_key6,
   cost.cost_owner_key7,
   cost.cost_owner_key8,
   cost.parent_cost_num,
   cost.port_num,
   cost.pos_group_num,
   cost.acct_num,
   cost.cost_qty,
   cost.cost_qty_uom_code,
   cost.cost_qty_est_actual_ind,
   cost.cost_unit_price,
   cost.cost_price_curr_code,
   cost.cost_price_uom_code,
   cost.cost_price_est_actual_ind,
   cost.cost_amt,
   cost.cost_amt_type,
   cost.cost_vouchered_amt,
   cost.cost_drawn_bal_amt,
   cost.pay_method_code,
   cost.pay_term_code,
   cost.cost_pay_days,
   cost.credit_term_code,
   cost.cost_book_comp_num,
   cost.cost_book_comp_short_name,
   cost.cost_book_prd_date,
   cost.cost_book_curr_code,
   cost.cost_book_exch_rate,
   cost.cost_xrate_conv_ind,
   cost.creation_date,
   cost.creator_init,
   cost.cost_eff_date,
   cost.cost_due_date,
   cost.cost_due_date_mod_date,
   cost.cost_due_date_mod_init,
   cost.cost_approval_date,
   cost.cost_approval_init,
   cost.cost_gl_acct_cr_code,
   cost.cost_gl_acct_dr_code,
   cost.cost_gl_acct_mod_date,
   cost.cost_gl_acct_mod_init,
   cost.cost_gl_book_type_code,
   cost.cost_gl_book_date,
   cost.cost_gl_book_init,
   cost.cost_gl_offset_acct_code,
   cost.cost_short_cmnt,
   cost.cmnt_num,
   cost.cost_accrual_ind,
   cost.cost_price_mod_date,
   cost.cost_price_mod_init,
   cost.cost_partial_ind,
   cost.first_accrued_date,
   cost.cost_period_ind,
   cost.cost_pl_code,
   cost.cost_paid_date,
   cost.cost_credit_ind,
   cost.cost_center_code_debt,
   cost.cost_center_code_credit,
   cost.cost_send_id,
   cost.vc_acct_num,
   cost.cash_date,
   cost.po_number,
   cost.eff_date_override_trans_id,
   cost.finance_bank_num,
   cost.tax_status_code,
   cost.external_ref_key,
   cost.cost_rate_oid,
   cost.template_cost_num,
   cost.internal_cost_ind,
   cost.assay_final_ind,
   cost.qty_type,
   null,
   cost.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence,
   cost.user_mod_date,
   cost.summary_cost_num
from dbo.cost cost
    left outer join dbo.icts_transaction it
        on cost.trans_id = it.trans_id
union
select
   cost.cost_num,
   cost.cost_code,
   cost.cost_status,
   cost.cost_prim_sec_ind,
   cost.cost_est_final_ind,
   cost.cost_pay_rec_ind,
   cost.cost_type_code,
   cost.bus_cost_type_num,
   cost.bus_cost_state_num,
   cost.bus_cost_fate_num,
   cost.bus_cost_fate_mod_date,
   cost.bus_cost_fate_mod_init,
   cost.cost_owner_code,
   cost.cost_owner_key1,
   cost.cost_owner_key2,
   cost.cost_owner_key3,
   cost.cost_owner_key4,
   cost.cost_owner_key5,
   cost.cost_owner_key6,
   cost.cost_owner_key7,
   cost.cost_owner_key8,
   cost.parent_cost_num,
   cost.port_num,
   cost.pos_group_num,
   cost.acct_num,
   cost.cost_qty,
   cost.cost_qty_uom_code,
   cost.cost_qty_est_actual_ind,
   cost.cost_unit_price,
   cost.cost_price_curr_code,
   cost.cost_price_uom_code,
   cost.cost_price_est_actual_ind,
   cost.cost_amt,
   cost.cost_amt_type,
   cost.cost_vouchered_amt,
   cost.cost_drawn_bal_amt,
   cost.pay_method_code,
   cost.pay_term_code,
   cost.cost_pay_days,
   cost.credit_term_code,
   cost.cost_book_comp_num,
   cost.cost_book_comp_short_name,
   cost.cost_book_prd_date,
   cost.cost_book_curr_code,
   cost.cost_book_exch_rate,
   cost.cost_xrate_conv_ind,
   cost.creation_date,
   cost.creator_init,
   cost.cost_eff_date,
   cost.cost_due_date,
   cost.cost_due_date_mod_date,
   cost.cost_due_date_mod_init,
   cost.cost_approval_date,
   cost.cost_approval_init,
   cost.cost_gl_acct_cr_code,
   cost.cost_gl_acct_dr_code,
   cost.cost_gl_acct_mod_date,
   cost.cost_gl_acct_mod_init,
   cost.cost_gl_book_type_code,
   cost.cost_gl_book_date,
   cost.cost_gl_book_init,
   cost.cost_gl_offset_acct_code,
   cost.cost_short_cmnt,
   cost.cmnt_num,
   cost.cost_accrual_ind,
   cost.cost_price_mod_date,
   cost.cost_price_mod_init,
   cost.cost_partial_ind,
   cost.first_accrued_date,
   cost.cost_period_ind,
   cost.cost_pl_code,
   cost.cost_paid_date,
   cost.cost_credit_ind,
   cost.cost_center_code_debt,
   cost.cost_center_code_credit,
   cost.cost_send_id,
   cost.vc_acct_num,
   cost.cash_date,
   cost.po_number,
   cost.eff_date_override_trans_id,
   cost.finance_bank_num,
   cost.tax_status_code,
   cost.external_ref_key,
   cost.cost_rate_oid,
   cost.template_cost_num,
   cost.internal_cost_ind,
   cost.assay_final_ind,
   cost.qty_type,
   cost.resp_trans_id,
   cost.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence,
   cost.user_mod_date,
   cost.summary_cost_num
from dbo.aud_cost cost
    left outer join dbo.icts_transaction it
        on cost.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_cost_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_cost_all_rs] TO [public]
GO
