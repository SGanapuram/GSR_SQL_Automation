SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_credit_limit_rev]
(
   credit_limit_num,
   limit_uom_code,
   limit_direction,
   limit_type,
   cr_analyst_init,
   limit_amt,
   curr_exp_amt,
   limit_alarm_status,
   review_email_group,
   limit_cmnt_num,
   acct_num,
   lc_type_code,
   acct_country_ind,
   cmdty_code,
   country_code,
   order_type_code,
   gross_net_ind,
   exposure_method_type,
   include_subsidiary_ind,
   limit_amt_curr_code,
   res_exp_amt,
   limit_line_type,
   limit_sub_type,
   book_comp_num,
   prev_review_date,
   next_review_date,
   review_adv_notice_days,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   credit_limit_num,
   limit_uom_code,
   limit_direction,
   limit_type,
   cr_analyst_init,
   limit_amt,
   curr_exp_amt,
   limit_alarm_status,
   review_email_group,
   limit_cmnt_num,
   acct_num,
   lc_type_code,
   acct_country_ind,
   cmdty_code,
   country_code,
   order_type_code,
   gross_net_ind,
   exposure_method_type,
   include_subsidiary_ind,
   limit_amt_curr_code,
   res_exp_amt,
   limit_line_type,
   limit_sub_type,
   book_comp_num,
   prev_review_date,
   next_review_date,
   review_adv_notice_days,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_credit_limit
GO
GRANT SELECT ON  [dbo].[v_credit_limit_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_credit_limit_rev] TO [next_usr]
GO
