SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchVoucherRevPK]
(
   @asof_trans_id      bigint,
   @voucher_num        int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.voucher
where voucher_num = @voucher_num
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_instr_num,
      acct_num,
      asof_trans_id = @asof_trans_id,
      book_comp_acct_bank_id,
      cash_date,
      cmnt_num,
      cp_acct_bank_id,
      cpty_inv_curr_code,
      credit_term_code,
      cust_inv_recv_date,
      cust_inv_type_ind,
      custom_voucher_string,
      external_ref_key,
      invoice_exch_rate_comment,
      max_line_num,
      pay_method_code,
      pay_term_code,
      ref_voucher_num,
      resp_trans_id = null,
      revised_book_comp_bank_id,
      sap_invoice_number,
      special_bank_instr,
      trans_id,
      voch_tot_paid_amt,
      voucher_acct_name,
      voucher_approval_date,
      voucher_approval_init,
      voucher_arap_acct_code,
      voucher_auth_date,
      voucher_auth_init,
      voucher_auth_reqd_ind,
      voucher_book_comp_name,
      voucher_book_comp_num,
      voucher_book_curr_code,
      voucher_book_date,
      voucher_book_exch_rate,
      voucher_book_prd_date,
      voucher_cat_code,
      voucher_creation_date,
      voucher_creator_init,
      voucher_curr_code,
      voucher_cust_inv_amt,
      voucher_cust_inv_date,
      voucher_cust_ref_num,
      voucher_due_date,
      voucher_eff_date,
      voucher_expected_pay_date,
      voucher_hold_ind,
      voucher_inv_curr_code,
      voucher_inv_exch_rate,
      voucher_loi_num,
      voucher_mod_date,
      voucher_mod_init,
      voucher_num,
      voucher_paid_date,
      voucher_pay_days,
      voucher_pay_recv_ind,
      voucher_print_date,
      voucher_reversal_ind,
      voucher_send_to_arap_date,
      voucher_send_to_cust_date,
      voucher_short_cmnt,
      voucher_status,
      voucher_tot_amt,
      voucher_type_code,
      voucher_writeoff_date,
      voucher_writeoff_init,
      voucher_xrate_conv_ind
   from dbo.voucher
   where voucher_num = @voucher_num
end
else
begin
   select top 1
      acct_instr_num,
      acct_num,
      asof_trans_id = @asof_trans_id,
      book_comp_acct_bank_id,
      cash_date,
      cmnt_num,
      cp_acct_bank_id,
      cpty_inv_curr_code,
      credit_term_code,
      cust_inv_recv_date,
      cust_inv_type_ind,
      custom_voucher_string,
      external_ref_key,
      invoice_exch_rate_comment,
      max_line_num,
      pay_method_code,
      pay_term_code,
      ref_voucher_num,
      resp_trans_id,
      revised_book_comp_bank_id,
      sap_invoice_number,
      special_bank_instr,
      trans_id,
      voch_tot_paid_amt,
      voucher_acct_name,
      voucher_approval_date,
      voucher_approval_init,
      voucher_arap_acct_code,
      voucher_auth_date,
      voucher_auth_init,
      voucher_auth_reqd_ind,
      voucher_book_comp_name,
      voucher_book_comp_num,
      voucher_book_curr_code,
      voucher_book_date,
      voucher_book_exch_rate,
      voucher_book_prd_date,
      voucher_cat_code,
      voucher_creation_date,
      voucher_creator_init,
      voucher_curr_code,
      voucher_cust_inv_amt,
      voucher_cust_inv_date,
      voucher_cust_ref_num,
      voucher_due_date,
      voucher_eff_date,
      voucher_expected_pay_date,
      voucher_hold_ind,
      voucher_inv_curr_code,
      voucher_inv_exch_rate,
      voucher_loi_num,
      voucher_mod_date,
      voucher_mod_init,
      voucher_num,
      voucher_paid_date,
      voucher_pay_days,
      voucher_pay_recv_ind,
      voucher_print_date,
      voucher_reversal_ind,
      voucher_send_to_arap_date,
      voucher_send_to_cust_date,
      voucher_short_cmnt,
      voucher_status,
      voucher_tot_amt,
      voucher_type_code,
      voucher_writeoff_date,
      voucher_writeoff_init,
      voucher_xrate_conv_ind
   from dbo.aud_voucher
   where voucher_num = @voucher_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchVoucherRevPK] TO [next_usr]
GO
