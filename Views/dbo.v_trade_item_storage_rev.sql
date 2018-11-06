SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_storage_rev]
(
   trade_num,
   order_num,
   item_num,
   stored_cmdty_code,
   sublease_ind,
   storage_start_date,
   storage_end_date,
   storage_avail_ind,
   storage_prd,
   storage_prd_uom_code,
   shrinkage_qty,
   shrinkage_uom_code,
   loss_allowance_qty,
   loss_allowance_uom_code,
   min_operating_qty,
   min_operating_qty_uom_code,
   storage_loc_code,
   storage_subloc_name,
   del_term_code,
   mot_code,
   pay_days,
   pay_term_code,
   credit_term_code,
   pipeline_cycle_num,
   timing_cycle_year,
   tank_num,
   target_min_qty,	
   target_max_qty,
   capacity,
   min_op_req_qty,
   safe_fill,
   heel,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   stored_cmdty_code,
   sublease_ind,
   storage_start_date,
   storage_end_date,
   storage_avail_ind,
   storage_prd,
   storage_prd_uom_code,
   shrinkage_qty,
   shrinkage_uom_code,
   loss_allowance_qty,
   loss_allowance_uom_code,
   min_operating_qty,
   min_operating_qty_uom_code,
   storage_loc_code,
   storage_subloc_name,
   del_term_code,
   mot_code,
   pay_days,
   pay_term_code,
   credit_term_code,
   pipeline_cycle_num,
   timing_cycle_year,
   tank_num,
   target_min_qty,	
   target_max_qty,
   capacity,
   min_op_req_qty,
   safe_fill,
   heel,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_storage
GO
GRANT SELECT ON  [dbo].[v_trade_item_storage_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_storage_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_storage_rev', NULL, NULL
GO