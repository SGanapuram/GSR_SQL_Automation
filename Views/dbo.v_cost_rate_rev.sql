SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cost_rate_rev]
(
   oid,
   cost_num,
   rate,
   rate_curr_code,
   rate_uom_code,
   effective_date,
   formula_num,
   formula_ind,
   factor,
   is_fully_priced,
   formula_cost_num,
   librarary_formula_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   cost_num,
   rate,
   rate_curr_code,
   rate_uom_code,
   effective_date,
   formula_num,
   formula_ind,
   factor,
   is_fully_priced,
   formula_cost_num,
   librarary_formula_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_cost_rate
GO
GRANT SELECT ON  [dbo].[v_cost_rate_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cost_rate_rev] TO [next_usr]
GO
