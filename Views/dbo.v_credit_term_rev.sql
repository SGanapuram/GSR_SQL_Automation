SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_credit_term_rev]
(
   credit_term_code,
   credit_term_desc,
   credit_term_contr_desc,
   credit_secure_ind,
   doc_type_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   credit_term_code,
   credit_term_desc,
   credit_term_contr_desc,
   credit_secure_ind,
   doc_type_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_credit_term
GO
GRANT SELECT ON  [dbo].[v_credit_term_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_credit_term_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_credit_term_rev', NULL, NULL
GO
