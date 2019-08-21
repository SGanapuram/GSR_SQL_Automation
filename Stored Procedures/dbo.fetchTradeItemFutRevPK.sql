SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemFutRevPK]
(
   @asof_trans_id      bigint,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trade_item_fut
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      avg_fill_price,
      clr_brkr_comm_amt,
      clr_brkr_comm_curr_code,
      clr_brkr_comm_uom_code,
      clr_brkr_cont_num,
      clr_brkr_num,
      clr_brkr_ref_num,
      efp_trigger_num,
      exec_type_code,
      exercise_num,
      fill_qty_uom_code,
      fut_price,
      fut_price_curr_code,
      item_num,
      order_num,
      price_source_code,
      resp_trans_id = null,
      settlement_type,
      total_fill_qty,
      trade_num,
      trans_id,
      use_in_fifo_ind
   from dbo.trade_item_fut
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      avg_fill_price,
      clr_brkr_comm_amt,
      clr_brkr_comm_curr_code,
      clr_brkr_comm_uom_code,
      clr_brkr_cont_num,
      clr_brkr_num,
      clr_brkr_ref_num,
      efp_trigger_num,
      exec_type_code,
      exercise_num,
      fill_qty_uom_code,
      fut_price,
      fut_price_curr_code,
      item_num,
      order_num,
      price_source_code,
      resp_trans_id,
      settlement_type,
      total_fill_qty,
      trade_num,
      trans_id,
      use_in_fifo_ind
   from dbo.aud_trade_item_fut
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemFutRevPK] TO [next_usr]
GO
