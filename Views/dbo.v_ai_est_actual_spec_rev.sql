SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE view [dbo].[v_ai_est_actual_spec_rev]
(
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   spec_code,
   spec_actual_value,
   spec_actual_value_text,
   spec_provisional_val,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   use_in_formula_ind,
   use_in_cost_ind
)
as
select
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   spec_code,
   spec_actual_value,
   spec_actual_value_text,
   spec_provisional_val,
   trans_id,
   trans_id,
   resp_trans_id,
   use_in_formula_ind,
   use_in_cost_ind
from dbo.aud_ai_est_actual_spec
GO
GRANT SELECT ON  [dbo].[v_ai_est_actual_spec_rev] TO [next_usr]
GO
