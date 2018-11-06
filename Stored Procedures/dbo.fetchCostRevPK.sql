SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCostRevPK]
(
   @asof_trans_id      int,
   @cost_num           int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.cost
where cost_num = @cost_num
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_num,
      asof_trans_id = @asof_trans_id,
      assay_final_ind,
      bus_cost_fate_mod_date,
      bus_cost_fate_mod_init,
      bus_cost_fate_num,
      bus_cost_state_num,
      bus_cost_type_num,
      cash_date,
      cmnt_num,
      cost_accrual_ind,
      cost_amt,
      cost_amt_type,
      cost_approval_date,
      cost_approval_init,
      cost_book_comp_num,
      cost_book_curr_code,
      cost_book_exch_rate,
      cost_book_prd_date,
      cost_center_code_credit,
      cost_center_code_debt,
      cost_code,
      cost_credit_ind,
      cost_drawn_bal_amt,
      cost_due_date,
      cost_due_date_mod_date,
      cost_due_date_mod_init,
      cost_eff_date,
      cost_est_final_ind,
      cost_gl_acct_cr_code,
      cost_gl_acct_dr_code,
      cost_gl_acct_mod_date,
      cost_gl_acct_mod_init,
      cost_gl_book_date,
      cost_gl_book_init,
      cost_gl_book_type_code,
      cost_gl_offset_acct_code,
      cost_num,
      cost_owner_code,
      cost_owner_key1,
      cost_owner_key2,
      cost_owner_key3,
      cost_owner_key4,
      cost_owner_key5,
      cost_owner_key6,
      cost_owner_key7,
      cost_owner_key8,
      cost_paid_date,
      cost_partial_ind,
      cost_pay_days,
      cost_pay_rec_ind,
      cost_period_ind,
      cost_pl_code,
      cost_price_curr_code,
      cost_price_est_actual_ind,
      cost_price_mod_date,
      cost_price_mod_init,
      cost_price_uom_code,
      cost_prim_sec_ind,
      cost_qty,
      cost_qty_est_actual_ind,
      cost_qty_uom_code,
      cost_rate_oid,
      cost_send_id,
      cost_short_cmnt,
      cost_status,
      cost_type_code,
      cost_unit_price,
      cost_vouchered_amt,
      cost_xrate_conv_ind,
      creation_date,
      creator_init,
      credit_term_code,
      eff_date_override_trans_id,
      external_ref_key,
      finance_bank_num,
      first_accrued_date,
      internal_cost_ind,
      parent_cost_num,
      pay_method_code,
      pay_term_code,
      po_number,
      port_num,
      pos_group_num,
      qty_type,
      resp_trans_id = null,
      tax_status_code,
      template_cost_num,
      trans_id,
      vc_acct_num
   from dbo.cost
   where cost_num = @cost_num
end
else
begin
   select top 1
      acct_num,
      asof_trans_id = @asof_trans_id,
      assay_final_ind,
      bus_cost_fate_mod_date,
      bus_cost_fate_mod_init,
      bus_cost_fate_num,
      bus_cost_state_num,
      bus_cost_type_num,
      cash_date,
      cmnt_num,
      cost_accrual_ind,
      cost_amt,
      cost_amt_type,
      cost_approval_date,
      cost_approval_init,
      cost_book_comp_num,
      cost_book_curr_code,
      cost_book_exch_rate,
      cost_book_prd_date,
      cost_center_code_credit,
      cost_center_code_debt,
      cost_code,
      cost_credit_ind,
      cost_drawn_bal_amt,
      cost_due_date,
      cost_due_date_mod_date,
      cost_due_date_mod_init,
      cost_eff_date,
      cost_est_final_ind,
      cost_gl_acct_cr_code,
      cost_gl_acct_dr_code,
      cost_gl_acct_mod_date,
      cost_gl_acct_mod_init,
      cost_gl_book_date,
      cost_gl_book_init,
      cost_gl_book_type_code,
      cost_gl_offset_acct_code,
      cost_num,
      cost_owner_code,
      cost_owner_key1,
      cost_owner_key2,
      cost_owner_key3,
      cost_owner_key4,
      cost_owner_key5,
      cost_owner_key6,
      cost_owner_key7,
      cost_owner_key8,
      cost_paid_date,
      cost_partial_ind,
      cost_pay_days,
      cost_pay_rec_ind,
      cost_period_ind,
      cost_pl_code,
      cost_price_curr_code,
      cost_price_est_actual_ind,
      cost_price_mod_date,
      cost_price_mod_init,
      cost_price_uom_code,
      cost_prim_sec_ind,
      cost_qty,
      cost_qty_est_actual_ind,
      cost_qty_uom_code,
      cost_rate_oid,
      cost_send_id,
      cost_short_cmnt,
      cost_status,
      cost_type_code,
      cost_unit_price,
      cost_vouchered_amt,
      cost_xrate_conv_ind,
      creation_date,
      creator_init,
      credit_term_code,
      eff_date_override_trans_id,
      external_ref_key,
      finance_bank_num,
      first_accrued_date,
      internal_cost_ind,
      parent_cost_num,
      pay_method_code,
      pay_term_code,
      po_number,
      port_num,
      pos_group_num,
      qty_type,
      resp_trans_id,
      tax_status_code,
      template_cost_num,
      trans_id,
      vc_acct_num
   from dbo.aud_cost
   where cost_num = @cost_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCostRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCostRevPK', NULL, NULL
GO
