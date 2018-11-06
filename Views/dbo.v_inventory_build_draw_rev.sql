SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_inventory_build_draw_rev]
(
   inv_num,
   inv_b_d_num,
   inv_b_d_type,
   inv_b_d_status,
   trade_num,
   order_num,
   item_num,
   alloc_num,
   alloc_item_num,
   adj_qty,
   adj_qty_uom_code,
   inv_b_d_date,
   inv_b_d_qty,
   inv_b_d_actual_qty,
   inv_b_d_cost,
   inv_b_d_cost_curr_code,
   inv_b_d_cost_uom_code,
   inv_draw_b_d_num,
   inv_b_d_tax_status_code,
   cmnt_num,
   pos_group_num,
   r_inv_b_d_cost,
   unr_inv_b_d_cost,
   voyage_code,
   adj_type_ind,
   inv_b_d_cost_wacog,
   r_inv_b_d_cost_wacog,
   unr_inv_b_d_cost_wacog,
   inv_curr_actual_qty,	
   inv_curr_proj_qty,	
   associated_trade,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   inv_num,
   inv_b_d_num,
   inv_b_d_type,
   inv_b_d_status,
   trade_num,
   order_num,
   item_num,
   alloc_num,
   alloc_item_num,
   adj_qty,
   adj_qty_uom_code,
   inv_b_d_date,
   inv_b_d_qty,
   inv_b_d_actual_qty,
   inv_b_d_cost,
   inv_b_d_cost_curr_code,
   inv_b_d_cost_uom_code,
   inv_draw_b_d_num,
   inv_b_d_tax_status_code,
   cmnt_num,
   pos_group_num,
   r_inv_b_d_cost,
   unr_inv_b_d_cost,
   voyage_code,
   adj_type_ind,
   inv_b_d_cost_wacog,
   r_inv_b_d_cost_wacog,
   unr_inv_b_d_cost_wacog,
   inv_curr_actual_qty,	
   inv_curr_proj_qty,	
   associated_trade,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_inventory_build_draw
GO
GRANT SELECT ON  [dbo].[v_inventory_build_draw_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_inventory_build_draw_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_inventory_build_draw_rev', NULL, NULL
GO