SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchQuotePricingPeriodRevPK]
(
   @accum_num          smallint,
   @asof_trans_id      int,
   @item_num           smallint,
   @order_num          smallint,
   @qpp_num            smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.quote_pricing_period
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num and
      accum_num = @accum_num and
      qpp_num = @qpp_num
 
if @trans_id <= @asof_trans_id
begin
   select
      accum_num,
      asof_trans_id = @asof_trans_id,
      cal_impact_end_date,
      cal_impact_start_date,
      calendar_code,
      formula_body_num,
      formula_comp_num,
      formula_num,
      item_num,
      last_pricing_date,
      manual_override_ind,
      nominal_end_date,
      nominal_start_date,
      num_of_days_priced,
      num_of_pricing_days,
      open_price,
      order_num,
      price_curr_code,
      price_uom_code,
      priced_price,
      priced_qty,
      qpp_num,
      qty_uom_code,
      quote_end_date,
      quote_start_date,
      real_trading_prd,
      resp_trans_id = null,
      risk_trading_prd,
      total_qty,
      trade_num,
      trans_id
   from dbo.quote_pricing_period
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         accum_num = @accum_num and
         qpp_num = @qpp_num
end
else
begin
   select top 1
      accum_num,
      asof_trans_id = @asof_trans_id,
      cal_impact_end_date,
      cal_impact_start_date,
      calendar_code,
      formula_body_num,
      formula_comp_num,
      formula_num,
      item_num,
      last_pricing_date,
      manual_override_ind,
      nominal_end_date,
      nominal_start_date,
      num_of_days_priced,
      num_of_pricing_days,
      open_price,
      order_num,
      price_curr_code,
      price_uom_code,
      priced_price,
      priced_qty,
      qpp_num,
      qty_uom_code,
      quote_end_date,
      quote_start_date,
      real_trading_prd,
      resp_trans_id,
      risk_trading_prd,
      total_qty,
      trade_num,
      trans_id
   from dbo.aud_quote_pricing_period
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         accum_num = @accum_num and
         qpp_num = @qpp_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchQuotePricingPeriodRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchQuotePricingPeriodRevPK', NULL, NULL
GO
