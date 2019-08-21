SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cost_equalization_rate_rev]
(
   cost_num,
   spec_code,
   effective_date,
   min_spec_value,
   max_spec_value,
   rate_for_low_end,
   rate_for_high_end,
   cost_rate_curr_code,
   cost_rate_uom_code,
   calc_factor,
   calc_factor_oper,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   cost_num,
   spec_code,
   effective_date,
   min_spec_value,
   max_spec_value,
   rate_for_low_end,
   rate_for_high_end,
   cost_rate_curr_code,
   cost_rate_uom_code,
   calc_factor,
   calc_factor_oper,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_cost_equalization_rate
GO
GRANT SELECT ON  [dbo].[v_cost_equalization_rate_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cost_equalization_rate_rev] TO [next_usr]
GO
