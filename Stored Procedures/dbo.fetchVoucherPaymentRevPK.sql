SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchVoucherPaymentRevPK]
(
   @asof_trans_id        bigint,
   @voucher_num          int,
   @voucher_pay_num      smallint
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.voucher_payment
where voucher_num = @voucher_num and
      voucher_pay_num = @voucher_pay_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cmnt_num,
      confirmed_amt,
      confirmed_amt_curr_code,
      confirmed_by_bank,
      confirmed_by_cp,
      effective_acct_bank_id,
      paid_date,
      payee_init,
      payment_approval_trans_id,
      payment_status,
      processed_date,
      resp_trans_id = null,
      sent_on_date,
      trans_id,
      value_date,
      voucher_num,
      voucher_pay_amt,
      voucher_pay_amt_curr_code,
      voucher_pay_num,
      voucher_pay_ref,
      voucher_payment_applied_ind
   from dbo.voucher_payment
   where voucher_num = @voucher_num and
         voucher_pay_num = @voucher_pay_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cmnt_num,
      confirmed_amt,
      confirmed_amt_curr_code,
      confirmed_by_bank,
      confirmed_by_cp,
      effective_acct_bank_id,
      paid_date,
      payee_init,
      payment_approval_trans_id,
      payment_status,
      processed_date,
      resp_trans_id,
      sent_on_date,
      trans_id,
      value_date,
      voucher_num,
      voucher_pay_amt,
      voucher_pay_amt_curr_code,
      voucher_pay_num,
      voucher_pay_ref,
      voucher_payment_applied_ind
   from dbo.aud_voucher_payment
   where voucher_num = @voucher_num and
         voucher_pay_num = @voucher_pay_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchVoucherPaymentRevPK] TO [next_usr]
GO
