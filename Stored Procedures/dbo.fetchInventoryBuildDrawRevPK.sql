SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchInventoryBuildDrawRevPK]
(
   @asof_trans_id   bigint,
   @inv_b_d_num     int,
   @inv_num         int
)
as
set nocount on
declare @trans_id   bigint

select @trans_id = trans_id
from dbo.inventory_build_draw
where inv_num = @inv_num and
      inv_b_d_num = @inv_b_d_num

if @trans_id <= @asof_trans_id
begin
   select 
      adj_qty,
      adj_qty_uom_code,
      adj_type_ind,
      alloc_item_num,
      alloc_num,
      asof_trans_id = @asof_trans_id,
      associated_cpty,
	    associated_trade,
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
         inv_b_d_num = @inv_b_d_num
end
else
begin
   select top 1
      adj_qty,
      adj_qty_uom_code,
      adj_type_ind,
      alloc_item_num,
      alloc_num,
      asof_trans_id = @asof_trans_id,
      associated_cpty,
	    associated_trade,
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
         inv_b_d_num = @inv_b_d_num and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return

GO
GRANT EXECUTE ON  [dbo].[fetchInventoryBuildDrawRevPK] TO [next_usr]
GO
