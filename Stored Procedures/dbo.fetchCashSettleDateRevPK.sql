SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchCashSettleDateRevPK]
(
   @asof_trans_id        int,
   @cash_settle_num      smallint,
   @order_num            smallint,
   @trade_num            int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.cash_settle_date
where trade_num = @trade_num and
      order_num = @order_num and
      cash_settle_num = @cash_settle_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cash_settle_date,
      cash_settle_num,
      cash_settle_status,
      order_num,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.cash_settle_date
   where trade_num = @trade_num and
         order_num = @order_num and
         cash_settle_num = @cash_settle_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cash_settle_date,
      cash_settle_num,
      cash_settle_status,
      order_num,
      resp_trans_id,
      trade_num,
      trans_id
   from dbo.aud_cash_settle_date
   where trade_num = @trade_num and
         order_num = @order_num and
         cash_settle_num = @cash_settle_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchCashSettleDateRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchCashSettleDateRevPK', NULL, NULL
GO
