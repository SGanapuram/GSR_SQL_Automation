SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_account_rev]
(
   acct_num,
   acct_short_name,
   acct_full_name,
   acct_status,
   acct_type_code,
   acct_parent_ind,
   acct_sub_ind,
   acct_vat_code,
   acct_fiscal_code,
   acct_sub_type_code,
   contract_cmnt_num,
   man_input_sec_qty_required,
   legal_entity_num,
   risk_transfer_ind_code,
   govt_code,
   allows_netout,
   allows_bookout,
   master_agreement_date,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   acct_num,
   acct_short_name,
   acct_full_name,
   acct_status,
   acct_type_code,
   acct_parent_ind,
   acct_sub_ind,
   acct_vat_code,
   acct_fiscal_code,
   acct_sub_type_code,
   contract_cmnt_num,
   man_input_sec_qty_required,
   legal_entity_num,
   risk_transfer_ind_code,
   govt_code,
   allows_netout,
   allows_bookout,
   master_agreement_date,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_account
GO
GRANT SELECT ON  [dbo].[v_account_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_account_rev] TO [next_usr]
GO
