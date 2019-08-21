SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCreditLimitRevPK]
(
   @asof_trans_id         bigint,
   @credit_limit_num      int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.credit_limit
where credit_limit_num = @credit_limit_num
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_country_ind,
      acct_num,
      asof_trans_id = @asof_trans_id,
      book_comp_num,
      cmdty_code,
      country_code,
      cr_analyst_init,
      credit_limit_num,
      curr_exp_amt,
      exposure_method_type,
      gross_net_ind,
      include_subsidiary_ind,
      lc_type_code,
      limit_alarm_status,
      limit_amt,
      limit_amt_curr_code,
      limit_cmnt_num,
      limit_direction,
      limit_line_type,
      limit_sub_type,
      limit_type,
      limit_uom_code,
      next_review_date,
      order_type_code,
      prev_review_date,
      res_exp_amt,
      resp_trans_id = null,
      review_adv_notice_days,
      review_email_group,
      trans_id
   from dbo.credit_limit
   where credit_limit_num = @credit_limit_num
end
else
begin
   select top 1
      acct_country_ind,
      acct_num,
      asof_trans_id = @asof_trans_id,
      book_comp_num,
      cmdty_code,
      country_code,
      cr_analyst_init,
      credit_limit_num,
      curr_exp_amt,
      exposure_method_type,
      gross_net_ind,
      include_subsidiary_ind,
      lc_type_code,
      limit_alarm_status,
      limit_amt,
      limit_amt_curr_code,
      limit_cmnt_num,
      limit_direction,
      limit_line_type,
      limit_sub_type,
      limit_type,
      limit_uom_code,
      next_review_date,
      order_type_code,
      prev_review_date,
      res_exp_amt,
      resp_trans_id,
      review_adv_notice_days,
      review_email_group,
      trans_id
   from dbo.aud_credit_limit
   where credit_limit_num = @credit_limit_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCreditLimitRevPK] TO [next_usr]
GO
