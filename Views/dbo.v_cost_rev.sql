SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cost_rev]
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
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
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
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_cost
GO
GRANT SELECT ON  [dbo].[v_cost_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cost_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_cost_rev', NULL, NULL
GO
