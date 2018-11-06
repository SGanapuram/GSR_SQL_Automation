SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemTransportRevPK]
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
from dbo.trade_item_transport
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      capacity,
      container_ind,
      credit_term_code,
      del_loc_code,
      demurrage_curr_code,
      demurrage_periodicity,
      demurrage_price,
      disch_date_from,
      disch_date_to,
      dispatch_curr_code,
      dispatch_periodicity,
      dispatch_price,
      free_time,
      free_time_uom_code,
      heel,
      item_num,
      load_date_from,
      load_date_to,
      load_loc_code,
      loss_allowance_qty,
      loss_allowance_uom_code,
      max_qty,
      max_qty_uom_code,
      min_op_req_qty,
      min_qty,
      min_qty_uom_code,
      min_ship_qty,
      min_ship_qty_uom_code,
      mot_code,
      number_of_trucks,
      order_num,
      overrun_curr_code,
      overrun_price,
      overrun_uom_code,
      pay_days,
      pay_term_code,
      pipeline_cycle_num,
      pump_rate_qty,
      pump_rate_qty_uom_code,
      pump_rate_time_uom_code,
      resp_trans_id = null,
      safe_fill,
      shrinkage_qty,
      shrinkage_uom_code,
      tank_num,
      target_max_qty,
      target_min_qty,
      timing_cycle_year,
      tol_qty,
      tol_qty_uom_code,
      tol_sign,
      trade_num,
      trans_id,
      transport_cmdty_code,
      transportation
   from dbo.trade_item_transport
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      capacity,
      container_ind,
      credit_term_code,
      del_loc_code,
      demurrage_curr_code,
      demurrage_periodicity,
      demurrage_price,
      disch_date_from,
      disch_date_to,
      dispatch_curr_code,
      dispatch_periodicity,
      dispatch_price,
      free_time,
      free_time_uom_code,
      heel,
      item_num,
      load_date_from,
      load_date_to,
      load_loc_code,
      loss_allowance_qty,
      loss_allowance_uom_code,
      max_qty,
      max_qty_uom_code,
      min_op_req_qty,
      min_qty,
      min_qty_uom_code,
      min_ship_qty,
      min_ship_qty_uom_code,
      mot_code,
      number_of_trucks,
      order_num,
      overrun_curr_code,
      overrun_price,
      overrun_uom_code,
      pay_days,
      pay_term_code,
      pipeline_cycle_num,
      pump_rate_qty,
      pump_rate_qty_uom_code,
      pump_rate_time_uom_code,
      resp_trans_id,
      safe_fill,
      shrinkage_qty,
      shrinkage_uom_code,
      tank_num,
      target_max_qty,
      target_min_qty,
      timing_cycle_year,
      tol_qty,
      tol_qty_uom_code,
      tol_sign,
      trade_num,
      trans_id,
      transport_cmdty_code,
      transportation
   from dbo.aud_trade_item_transport
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemTransportRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemTransportRevPK', NULL, NULL
GO
