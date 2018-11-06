SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemStorageRevPK]
(
   @asof_trans_id      int,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.trade_item_storage
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      capacity,
      credit_term_code,
      del_term_code,
      heel,
      item_num,
      loss_allowance_qty,
      loss_allowance_uom_code,
      min_op_req_qty,
      min_operating_qty,
      min_operating_qty_uom_code,
      mot_code,
      order_num,
      pay_days,
      pay_term_code,
      pipeline_cycle_num,
      resp_trans_id = null,
      safe_fill,
      shrinkage_qty,
      shrinkage_uom_code,
      storage_avail_ind,
      storage_end_date,
      storage_loc_code,
      storage_prd,
      storage_prd_uom_code,
      storage_start_date,
      storage_subloc_name,
      stored_cmdty_code,
      sublease_ind,
      tank_num,
      target_max_qty,
      target_min_qty,
      timing_cycle_year,
      trade_num,
      trans_id
   from dbo.trade_item_storage
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      capacity,
      credit_term_code,
      del_term_code,
      heel,
      item_num,
      loss_allowance_qty,
      loss_allowance_uom_code,
      min_op_req_qty,
      min_operating_qty,
      min_operating_qty_uom_code,
      mot_code,
      order_num,
      pay_days,
      pay_term_code,
      pipeline_cycle_num,
      resp_trans_id,
      safe_fill,
      shrinkage_qty,
      shrinkage_uom_code,
      storage_avail_ind,
      storage_end_date,
      storage_loc_code,
      storage_prd,
      storage_prd_uom_code,
      storage_start_date,
      storage_subloc_name,
      stored_cmdty_code,
      sublease_ind,
      tank_num,
      target_max_qty,
      target_min_qty,
      timing_cycle_year,
      trade_num,
      trans_id
   from dbo.aud_trade_item_storage
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemStorageRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemStorageRevPK', NULL, NULL
GO
