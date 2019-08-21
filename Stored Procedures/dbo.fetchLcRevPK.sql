SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchLcRevPK]
(
   @asof_trans_id      bigint,
   @lc_num             int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.lc
where lc_num = @lc_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      collateral_type_code,
      external_ref_key,
      guarantor_acct_num,
      lc_advising_bank,
      lc_applicant,
      lc_beneficiary,
      lc_confirm_date,
      lc_confirm_reqd_ind,
      lc_confirming_bank,
      lc_cr_analyst_init,
      lc_custom_column1,
      lc_custom_column2,
      lc_dispute_ind,
      lc_dispute_status,
      lc_evergreen_ext_days,
      lc_evergreen_roll_days,
      lc_evergreen_status,
      lc_exp_date,
      lc_exp_days,
      lc_exp_days_oper,
      lc_exp_event,
      lc_exp_imp_ind,
      lc_final_ind,
      lc_issue_date,
      lc_issuing_bank,
      lc_loi_presented_ind,
      lc_negotiate_clause,
      lc_negotiating_bank,
      lc_netting_ind,
      lc_num,
      lc_office_loc_code,
      lc_priority,
      lc_request_date,
      lc_short_cmnt,
      lc_stale_doc_allow_ind,
      lc_stale_doc_days,
      lc_status_code,
      lc_template_creator,
      lc_template_ind,
      lc_template_name,
      lc_transact_or_blanket,
      lc_type_code,
      lc_usage_code,
      other_lcs_rel_ind,
      pcg_type_code,
      resp_trans_id = null,
      trans_id
   from dbo.lc
   where lc_num = @lc_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      collateral_type_code,
      external_ref_key,
      guarantor_acct_num,
      lc_advising_bank,
      lc_applicant,
      lc_beneficiary,
      lc_confirm_date,
      lc_confirm_reqd_ind,
      lc_confirming_bank,
      lc_cr_analyst_init,
      lc_custom_column1,
      lc_custom_column2,
      lc_dispute_ind,
      lc_dispute_status,
      lc_evergreen_ext_days,
      lc_evergreen_roll_days,
      lc_evergreen_status,
      lc_exp_date,
      lc_exp_days,
      lc_exp_days_oper,
      lc_exp_event,
      lc_exp_imp_ind,
      lc_final_ind,
      lc_issue_date,
      lc_issuing_bank,
      lc_loi_presented_ind,
      lc_negotiate_clause,
      lc_negotiating_bank,
      lc_netting_ind,
      lc_num,
      lc_office_loc_code,
      lc_priority,
      lc_request_date,
      lc_short_cmnt,
      lc_stale_doc_allow_ind,
      lc_stale_doc_days,
      lc_status_code,
      lc_template_creator,
      lc_template_ind,
      lc_template_name,
      lc_transact_or_blanket,
      lc_type_code,
      lc_usage_code,
      other_lcs_rel_ind,
      pcg_type_code,
      resp_trans_id,
      trans_id
   from dbo.aud_lc
   where lc_num = @lc_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchLcRevPK] TO [next_usr]
GO
