SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemFillRevPK]
(
   @asof_trans_id      bigint,
   @item_fill_num      smallint,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trade_item_fill
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num and
      item_fill_num = @item_fill_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      broker_fifo_qty,
      bsi_fill_num,
      efp_post_date,
      external_trade_num,
      fifo_qty,
      fill_closed_qty,
      fill_date,
      fill_price,
      fill_price_curr_code,
      fill_price_uom_code,
      fill_qty,
      fill_qty_uom_code,
      fill_status,
      in_out_house_ind,
      inhouse_fill_num,
      inhouse_item_num,
      inhouse_order_num,
      inhouse_trade_num,
      item_fill_num,
      item_num,
      order_num,
      outhouse_acct_alloc,
      outhouse_profit_center,
      port_match_qty,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.trade_item_fill
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         item_fill_num = @item_fill_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      broker_fifo_qty,
      bsi_fill_num,
      efp_post_date,
      external_trade_num,
      fifo_qty,
      fill_closed_qty,
      fill_date,
      fill_price,
      fill_price_curr_code,
      fill_price_uom_code,
      fill_qty,
      fill_qty_uom_code,
      fill_status,
      in_out_house_ind,
      inhouse_fill_num,
      inhouse_item_num,
      inhouse_order_num,
      inhouse_trade_num,
      item_fill_num,
      item_num,
      order_num,
      outhouse_acct_alloc,
      outhouse_profit_center,
      port_match_qty,
      resp_trans_id,
      trade_num,
      trans_id
   from dbo.aud_trade_item_fill
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         item_fill_num = @item_fill_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemFillRevPK] TO [next_usr]
GO
