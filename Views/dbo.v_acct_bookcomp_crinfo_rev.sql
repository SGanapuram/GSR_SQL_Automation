SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_acct_bookcomp_crinfo_rev]
(
   acct_bookcomp_key,
   dflt_cr_term_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   acct_bookcomp_key,
   dflt_cr_term_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_acct_bookcomp_crinfo
GO
GRANT SELECT ON  [dbo].[v_acct_bookcomp_crinfo_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_acct_bookcomp_crinfo_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_acct_bookcomp_crinfo_rev', NULL, NULL
GO
