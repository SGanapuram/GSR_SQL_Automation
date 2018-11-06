SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
create proc [dbo].[fetchInventoryToInvBuildDraw]
   @asof_trans_id   int,
   @inv_num         int
as
declare @trans_id   int

   select 
       adj_qty,
       adj_qty_uom_code,
       adj_type_ind,
       alloc_item_num,
       alloc_num,
       asof_trans_id = @asof_trans_id,
       cmnt_num,
       inv_b_d_actual_qty,
       inv_b_d_cost,
       inv_b_d_cost_curr_code,
       inv_b_d_cost_uom_code,
       inv_b_d_cost_wacog,
       inv_b_d_date,
       inv_b_d_num,
       inv_b_d_qty,
       inv_b_d_status,
       inv_b_d_tax_status_code,
       inv_b_d_type,
       inv_curr_actual_qty,
       inv_curr_proj_qty,
       inv_draw_b_d_num,
       inv_num,
       item_num,
       order_num,
       pos_group_num,
       r_inv_b_d_cost,
       r_inv_b_d_cost_wacog,
       resp_trans_id = null,
       trade_num,
       trans_id,
       unr_inv_b_d_cost,
       unr_inv_b_d_cost_wacog,
       voyage_code
   from dbo.inventory_build_draw
   where inv_num = @inv_num and 
         trans_id <= @asof_trans_id
   union
   select 
       adj_qty,
       adj_qty_uom_code,
       adj_type_ind,
       alloc_item_num,
       alloc_num,
       asof_trans_id = @asof_trans_id,
       cmnt_num,
       inv_b_d_actual_qty,
       inv_b_d_cost,
       inv_b_d_cost_curr_code,
       inv_b_d_cost_uom_code,
       inv_b_d_cost_wacog,
       inv_b_d_date,
       inv_b_d_num,
       inv_b_d_qty,
       inv_b_d_status,
       inv_b_d_tax_status_code,
       inv_b_d_type,
       inv_curr_actual_qty,
       inv_curr_proj_qty,
       inv_draw_b_d_num,
       inv_num,
       item_num,
       order_num,
       pos_group_num,
       r_inv_b_d_cost,
       r_inv_b_d_cost_wacog,
       resp_trans_id,
       trade_num,
       trans_id,
       unr_inv_b_d_cost,
       unr_inv_b_d_cost_wacog,
       voyage_code
   from dbo.aud_inventory_build_draw
   where inv_num = @inv_num and 
         (trans_id <= @asof_trans_id and 
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchInventoryToInvBuildDraw] TO [next_usr]
GO
