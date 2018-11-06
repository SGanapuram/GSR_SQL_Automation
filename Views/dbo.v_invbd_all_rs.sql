SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_invbd_all_rs]
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
   trans_id,
   resp_trans_id,
   adj_type_ind,
   inv_b_d_cost_wacog,
   r_inv_b_d_cost_wacog,
   unr_inv_b_d_cost_wacog,
   inv_curr_actual_qty,
   inv_curr_proj_qty,
   associated_trade,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.inv_num,
   maintb.inv_b_d_num,
   maintb.inv_b_d_type,
   maintb.inv_b_d_status,
   maintb.trade_num,
   maintb.order_num,
   maintb.item_num,
   maintb.alloc_num,
   maintb.alloc_item_num,
   maintb.adj_qty,
   maintb.adj_qty_uom_code,
   maintb.inv_b_d_date,
   maintb.inv_b_d_qty,
   maintb.inv_b_d_actual_qty,
   maintb.inv_b_d_cost,
   maintb.inv_b_d_cost_curr_code,
   maintb.inv_b_d_cost_uom_code,
   maintb.inv_draw_b_d_num,
   maintb.inv_b_d_tax_status_code,
   maintb.cmnt_num,
   maintb.pos_group_num,
   maintb.r_inv_b_d_cost,
   maintb.unr_inv_b_d_cost,
   maintb.voyage_code,
   maintb.trans_id,
   null,
   maintb.adj_type_ind,
   maintb.inv_b_d_cost_wacog,
   maintb.r_inv_b_d_cost_wacog,
   maintb.unr_inv_b_d_cost_wacog,
   maintb.inv_curr_actual_qty,
   maintb.inv_curr_proj_qty,
   maintb.associated_trade,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.inventory_build_draw maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.inv_num,
   audtb.inv_b_d_num,
   audtb.inv_b_d_type,
   audtb.inv_b_d_status,
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.alloc_num,
   audtb.alloc_item_num,
   audtb.adj_qty,
   audtb.adj_qty_uom_code,
   audtb.inv_b_d_date,
   audtb.inv_b_d_qty,
   audtb.inv_b_d_actual_qty,
   audtb.inv_b_d_cost,
   audtb.inv_b_d_cost_curr_code,
   audtb.inv_b_d_cost_uom_code,
   audtb.inv_draw_b_d_num,
   audtb.inv_b_d_tax_status_code,
   audtb.cmnt_num,
   audtb.pos_group_num,
   audtb.r_inv_b_d_cost,
   audtb.unr_inv_b_d_cost,
   audtb.voyage_code,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.adj_type_ind,
   audtb.inv_b_d_cost_wacog,
   audtb.r_inv_b_d_cost_wacog,
   audtb.unr_inv_b_d_cost_wacog,
   audtb.inv_curr_actual_qty,
   audtb.inv_curr_proj_qty,
   audtb.associated_trade,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_inventory_build_draw audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_invbd_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_invbd_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_invbd_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_invbd_all_rs', NULL, NULL
GO
