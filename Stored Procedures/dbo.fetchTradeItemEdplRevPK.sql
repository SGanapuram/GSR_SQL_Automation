SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemEdplRevPK]
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
from dbo.trade_item_edpl
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      addl_cost_sum,
      asof_date,
      asof_trans_id = @asof_trans_id,
      closed_trade_value,
      day_pl,
      item_num,
      latest_pl,
      market_value,
      open_trade_value,
      order_num,
      resp_trans_id = null,
      trade_modified_after_pass,
      trade_num,
      trade_qty,
      trans_id
   from dbo.trade_item_edpl
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      addl_cost_sum,
      asof_date,
      asof_trans_id = @asof_trans_id,
      closed_trade_value,
      day_pl,
      item_num,
      latest_pl,
      market_value,
      open_trade_value,
      order_num,
      resp_trans_id,
      trade_modified_after_pass,
      trade_num,
      trade_qty,
      trans_id
   from dbo.aud_trade_item_edpl
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemEdplRevPK] TO [next_usr]
GO
