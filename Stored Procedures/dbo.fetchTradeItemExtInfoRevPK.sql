SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemExtInfoRevPK]
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
from dbo.trade_item_ext_info
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      custom_field1,
      custom_field2,
      custom_field3,
      custom_field4,
      custom_field5,
      custom_field6,
      custom_field7,
      custom_field8,
      item_num,
      order_num,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.trade_item_ext_info
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      custom_field1,
      custom_field2,
      custom_field3,
      custom_field4,
      custom_field5,
      custom_field6,
      custom_field7,
      custom_field8,
      item_num,
      order_num,
      resp_trans_id,
      trade_num,
      trans_id
   from dbo.aud_trade_item_ext_info
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemExtInfoRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemExtInfoRevPK', NULL, NULL
GO
