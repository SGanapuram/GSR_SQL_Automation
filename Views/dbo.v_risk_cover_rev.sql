SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_risk_cover_rev]
(
   risk_cover_num,
   instr_type_code,
   rc_status_code,
   guarantee_acct_num,
   covered_percent,
   max_covered_amt,
   guarantee_ref_num,
   guarantee_start_date,
   guarantee_end_date,
   min_num_of_days,
   analyst_init,
   office_loc_code,
   disc_date,
   disc_rec_amt,
   disc_rec_curr_code,
   cmnt_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   risk_cover_num,
   instr_type_code,
   rc_status_code,
   guarantee_acct_num,
   covered_percent,
   max_covered_amt,
   guarantee_ref_num,
   guarantee_start_date,
   guarantee_end_date,
   min_num_of_days,
   analyst_init,
   office_loc_code,
   disc_date,
   disc_rec_amt,
   disc_rec_curr_code,
   cmnt_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_risk_cover
GO
GRANT SELECT ON  [dbo].[v_risk_cover_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_risk_cover_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_risk_cover_rev', NULL, NULL
GO
