SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_account_group_rev]
(
   related_acct_num,
   acct_num,
   acct_group_type_code,
   parent_acct_own_pcnt,
   acct_group_relation,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   related_acct_num,
   acct_num,
   acct_group_type_code,
   parent_acct_own_pcnt,
   acct_group_relation,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_account_group
GO
GRANT SELECT ON  [dbo].[v_account_group_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_account_group_rev] TO [next_usr]
GO
