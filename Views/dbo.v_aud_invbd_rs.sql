SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_aud_invbd_rs]
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
   resp_trans_id,
   trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   inv_curr_actual_qty,
   inv_curr_proj_qty,
   associated_trade,
   associated_cpty
)
as
select
   inv_b_d.inv_num,
   inv_b_d.inv_b_d_num,
   inv_b_d.inv_b_d_type,
   inv_b_d.inv_b_d_status,
   inv_b_d.trade_num,
   inv_b_d.order_num,
   inv_b_d.item_num,
   inv_b_d.alloc_num,
   inv_b_d.alloc_item_num,
   inv_b_d.adj_qty,
   inv_b_d.adj_qty_uom_code,
   inv_b_d.inv_b_d_date,
   inv_b_d.inv_b_d_qty,
   inv_b_d.inv_b_d_actual_qty,
   inv_b_d.inv_b_d_cost,
   inv_b_d.inv_b_d_cost_curr_code,
   inv_b_d.inv_b_d_cost_uom_code,
   inv_b_d.inv_draw_b_d_num,
   inv_b_d.inv_b_d_tax_status_code,
   inv_b_d.cmnt_num,
   inv_b_d.pos_group_num,
   inv_b_d.r_inv_b_d_cost,
   inv_b_d.unr_inv_b_d_cost,
   inv_b_d.voyage_code,
   inv_b_d.adj_type_ind,
   inv_b_d.inv_b_d_cost_wacog,
   inv_b_d.r_inv_b_d_cost_wacog,
   inv_b_d.unr_inv_b_d_cost_wacog,	
   inv_b_d.resp_trans_id,
   inv_b_d.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   inv_b_d.inv_curr_actual_qty,
   inv_b_d.inv_curr_proj_qty,
   inv_b_d.associated_trade,
   inv_b_d.associated_cpty
from aud_inventory_build_draw inv_b_d
    left outer join dbo.icts_transaction it
        on inv_b_d.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_aud_invbd_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_aud_invbd_rs] TO [public]
GO
