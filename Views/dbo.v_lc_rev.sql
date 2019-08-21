SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_lc_rev]
(
   lc_num,
   lc_type_code,
   lc_exp_imp_ind,
   lc_usage_code,
   lc_status_code,
   lc_final_ind,
   lc_evergreen_status,
   lc_evergreen_roll_days,
   lc_evergreen_ext_days,
   lc_stale_doc_allow_ind,
   lc_stale_doc_days,
   lc_loi_presented_ind,
   lc_negotiate_clause,
   lc_confirm_reqd_ind,
   lc_confirm_date,
   lc_issue_date,
   lc_request_date,
   lc_exp_date,
   lc_exp_event,
   lc_exp_days,
   lc_exp_days_oper,
   lc_office_loc_code,
   lc_short_cmnt,
   lc_cr_analyst_init,
   lc_transact_or_blanket,
   lc_applicant,
   lc_beneficiary,
   lc_advising_bank,
   lc_issuing_bank,
   lc_negotiating_bank,
   lc_confirming_bank,
   guarantor_acct_num,
   pcg_type_code,
   collateral_type_code,
   lc_netting_ind,
   lc_template_ind,
   other_lcs_rel_ind,
   lc_template_name,
   lc_template_creator,
   external_ref_key,
   lc_dispute_ind,
   lc_dispute_status,
   lc_priority,
   lc_custom_column1,
   lc_custom_column2,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   lc_num,
   lc_type_code,
   lc_exp_imp_ind,
   lc_usage_code,
   lc_status_code,
   lc_final_ind,
   lc_evergreen_status,
   lc_evergreen_roll_days,
   lc_evergreen_ext_days,
   lc_stale_doc_allow_ind,
   lc_stale_doc_days,
   lc_loi_presented_ind,
   lc_negotiate_clause,
   lc_confirm_reqd_ind,
   lc_confirm_date,
   lc_issue_date,
   lc_request_date,
   lc_exp_date,
   lc_exp_event,
   lc_exp_days,
   lc_exp_days_oper,
   lc_office_loc_code,
   lc_short_cmnt,
   lc_cr_analyst_init,
   lc_transact_or_blanket,
   lc_applicant,
   lc_beneficiary,
   lc_advising_bank,
   lc_issuing_bank,
   lc_negotiating_bank,
   lc_confirming_bank,
   guarantor_acct_num,
   pcg_type_code,
   collateral_type_code,
   lc_netting_ind,
   lc_template_ind,
   other_lcs_rel_ind,
   lc_template_name,
   lc_template_creator,
   external_ref_key,
   lc_dispute_ind,
   lc_dispute_status,
   lc_priority,
   lc_custom_column1,
   lc_custom_column2,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_lc
GO
GRANT SELECT ON  [dbo].[v_lc_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_lc_rev] TO [next_usr]
GO
