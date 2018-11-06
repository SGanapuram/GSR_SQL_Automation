SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_payment_term_rev]
(
   pay_term_code,
   pay_term_desc,
   pay_days,
   pay_term_contr_desc,
   pay_term_event1,
   pay_term_event2,
   pay_term_event3,
   pay_term_ba_ind1,
   pay_term_ba_ind2,
   pay_term_ba_ind3,
   pay_term_days1,
   pay_term_days2,
   pay_term_days3,
   accounting_pay_term,
   accounting_trans_cat1,
   accounting_trans_cat2,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   pay_term_code,
   pay_term_desc,
   pay_days,
   pay_term_contr_desc,
   pay_term_event1,
   pay_term_event2,
   pay_term_event3,
   pay_term_ba_ind1,
   pay_term_ba_ind2,
   pay_term_ba_ind3,
   pay_term_days1,
   pay_term_days2,
   pay_term_days3,
   accounting_pay_term,
   accounting_trans_cat1,
   accounting_trans_cat2,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_payment_term
GO
GRANT SELECT ON  [dbo].[v_payment_term_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_payment_term_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_payment_term_rev', NULL, NULL
GO
