SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_formula_rev]
(
   formula_num,
   formula_name,
   formula_type,
   formula_use,
   formula_status,
   formula_curr_code,
   formula_uom_code,
   formula_precision,
   parent_formula_num,
   cmnt_num,
   use_alt_source_ind,
   monthly_pricing_inds,
   use_exec_price_ind,
   formula_rounding_level,
   modular_ind,
   price_assay_final_ind,
   max_qp_opt_end_date,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   formula_num,
   formula_name,
   formula_type,
   formula_use,
   formula_status,
   formula_curr_code,
   formula_uom_code,
   formula_precision,
   parent_formula_num,
   cmnt_num,
   use_alt_source_ind,
   monthly_pricing_inds,
   use_exec_price_ind,
   formula_rounding_level,
   modular_ind,
   price_assay_final_ind,
   max_qp_opt_end_date,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_formula
GO
GRANT SELECT ON  [dbo].[v_formula_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_formula_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_formula_rev', NULL, NULL
GO
