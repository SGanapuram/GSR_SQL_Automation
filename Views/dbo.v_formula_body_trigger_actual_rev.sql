SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_formula_body_trigger_actual_rev]                              
(                                                        
   formula_num,
   formula_body_num,
   trigger_num,
   parcel_num,
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   applied_trigger_pcnt,
   applied_trigger_qty,
   applied_trigger_qty_uom_code,
   actual_triggered_pcnt,
   actual_triggered_qty,
   actual_triggered_qty_uom_code,
   fully_triggered,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   trigger_actual_num,
   trigger_rem_bal
)                                                        
as                                                       
select                                                   
   formula_num,
   formula_body_num,
   trigger_num,
   parcel_num,
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   applied_trigger_pcnt,
   applied_trigger_qty,
   applied_trigger_qty_uom_code,
   actual_triggered_pcnt,
   actual_triggered_qty,
   actual_triggered_qty_uom_code,
   fully_triggered,
   trans_id,
   trans_id,
   resp_trans_id,
   trigger_actual_num,
   trigger_rem_bal	
from dbo.aud_formula_body_trigger_actual                               
GO
GRANT SELECT ON  [dbo].[v_formula_body_trigger_actual_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_formula_body_trigger_actual_rev] TO [next_usr]
GO
