SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_formula_component_rev]
(
   formula_num,
   formula_body_num,
   formula_comp_num,
   formula_comp_name,
   formula_comp_type,
   formula_comp_ref,
   formula_comp_val,
   commkt_key,
   trading_prd,
   price_source_code,
   formula_comp_val_type,
   formula_comp_pos_num,
   formula_comp_curr_code,
   formula_comp_uom_code,
   formula_comp_cmnt,
   linear_factor,
   is_type_weight_ind,
   formula_comp_label,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   formula_num,
   formula_body_num,
   formula_comp_num,
   formula_comp_name,
   formula_comp_type,
   formula_comp_ref,
   formula_comp_val,
   commkt_key,
   trading_prd,
   price_source_code,
   formula_comp_val_type,
   formula_comp_pos_num,
   formula_comp_curr_code,
   formula_comp_uom_code,
   formula_comp_cmnt,
   linear_factor,
   is_type_weight_ind,
   formula_comp_label,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_formula_component                                                      
GO
GRANT SELECT ON  [dbo].[v_formula_component_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_formula_component_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_formula_component_rev', NULL, NULL
GO
