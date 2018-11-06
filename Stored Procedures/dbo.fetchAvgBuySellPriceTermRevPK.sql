SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAvgBuySellPriceTermRevPK]
(
   @asof_trans_id      int,
   @formula_num        int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.avg_buy_sell_price_term
where formula_num = @formula_num
 
if @trans_id <= @asof_trans_id
begin
   select
      all_quotes_reqd_ind,
      asof_trans_id = @asof_trans_id,
      buyer_seller_opt,
      determination_mths_num,
      determination_opt,
      exclusion_days,
      formula_num,
      price_term_end_date,
      price_term_start_date,
      quote_type,
      resp_trans_id = null,
      roll_days,
      trans_id
   from dbo.avg_buy_sell_price_term
   where formula_num = @formula_num
end
else
begin
   select top 1
      all_quotes_reqd_ind,
      asof_trans_id = @asof_trans_id,
      buyer_seller_opt,
      determination_mths_num,
      determination_opt,
      exclusion_days,
      formula_num,
      price_term_end_date,
      price_term_start_date,
      quote_type,
      resp_trans_id,
      roll_days,
      trans_id
   from dbo.aud_avg_buy_sell_price_term
   where formula_num = @formula_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAvgBuySellPriceTermRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchAvgBuySellPriceTermRevPK', NULL, NULL
GO
