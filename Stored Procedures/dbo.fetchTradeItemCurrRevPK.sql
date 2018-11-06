SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemCurrRevPK]
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
from dbo.trade_item_curr
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      credit_term_code,
      item_num,
      order_num,
      pay_curr_amt,
      pay_curr_code,
      payment_date,
      rec_curr_amt,
      rec_curr_code,
      ref_spot_rate,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.trade_item_curr
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      credit_term_code,
      item_num,
      order_num,
      pay_curr_amt,
      pay_curr_code,
      payment_date,
      rec_curr_amt,
      rec_curr_code,
      ref_spot_rate,
      resp_trans_id,
      trade_num,
      trans_id
   from dbo.aud_trade_item_curr
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemCurrRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemCurrRevPK', NULL, NULL
GO
