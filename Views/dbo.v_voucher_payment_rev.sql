SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_voucher_payment_rev]
(
   voucher_num,
   voucher_pay_num,
   voucher_pay_amt,
   voucher_pay_amt_curr_code,
   voucher_pay_ref,
   voucher_payment_applied_ind,
   payment_approval_trans_id,
   sent_on_date,    
   payment_status,
   processed_date,
   paid_date,
   effective_acct_bank_id,
   confirmed_by_bank,
   confirmed_by_cp,
   value_date,
   confirmed_amt,
   confirmed_amt_curr_code,  
   cmnt_num,
   payee_init,
   trans_id,
   asof_trans_id,
   resp_trans_id)
as
select
   voucher_num,
   voucher_pay_num,
   voucher_pay_amt,
   voucher_pay_amt_curr_code,
   voucher_pay_ref,
   voucher_payment_applied_ind,
   payment_approval_trans_id,
   sent_on_date,    
   payment_status,
   processed_date,
   paid_date,
   effective_acct_bank_id,
   confirmed_by_bank,
   confirmed_by_cp,
   value_date,
   confirmed_amt,
   confirmed_amt_curr_code,  
   cmnt_num,
   payee_init,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_voucher_payment
GO
GRANT SELECT ON  [dbo].[v_voucher_payment_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_voucher_payment_rev] TO [next_usr]
GO
