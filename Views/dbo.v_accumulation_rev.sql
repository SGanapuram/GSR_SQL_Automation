SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_accumulation_rev]
(
   trade_num,
   order_num,
   item_num,
   accum_num,
   accum_start_date,
   accum_end_date,
   nominal_start_date,
   nominal_end_date,
   quote_start_date,
   quote_end_date,
   accum_qty,
   accum_qty_uom_code,
   total_price,
   price_curr_code,
   price_status,
   last_pricing_run_date,
   last_pricing_as_of_date,
   accum_creation_type,
   manual_override_ind,
   formula_precision,
   cmnt_num,
   formula_num,
   alloc_num,
   alloc_item_num,
   cost_num,
   idms_trig_bb_ref_num,
   exercised_by_init,
   max_qpp_num,
   ai_est_actual_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   accum_num,
   accum_start_date,
   accum_end_date,
   nominal_start_date,
   nominal_end_date,
   quote_start_date,
   quote_end_date,
   accum_qty,
   accum_qty_uom_code,
   total_price,
   price_curr_code,
   price_status,
   last_pricing_run_date,
   last_pricing_as_of_date,
   accum_creation_type,
   manual_override_ind,
   formula_precision,
   cmnt_num,
   formula_num,
   alloc_num,
   alloc_item_num,
   cost_num,
   idms_trig_bb_ref_num,
   exercised_by_init,
   max_qpp_num,
   ai_est_actual_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_accumulation                                                         
GO
GRANT SELECT ON  [dbo].[v_accumulation_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_accumulation_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_accumulation_rev', NULL, NULL
GO
