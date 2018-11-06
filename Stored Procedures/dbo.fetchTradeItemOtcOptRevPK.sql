SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemOtcOptRevPK]
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
from dbo.trade_item_otc_opt
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      apo_special_cond_code,
      asof_trans_id = @asof_trans_id,
      credit_term_code,
      desired_opt_eval_method,
      desired_otc_opt_code,
      exp_date,
      exp_zone_code,
      item_num,
      lookback_cond_code,
      lookback_last_date,
      opt_type,
      order_num,
      pay_term_code,
      premium,
      premium_curr_code,
      premium_pay_date,
      premium_uom_code,
      price_date_from,
      price_date_to,
      put_call_ind,
      resp_trans_id = null,
      settlement_type,
      strike_excer_date,
      strike_price,
      strike_price_curr_code,
      strike_price_uom_code,
      trade_num,
      trans_id
   from dbo.trade_item_otc_opt
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      apo_special_cond_code,
      asof_trans_id = @asof_trans_id,
      credit_term_code,
      desired_opt_eval_method,
      desired_otc_opt_code,
      exp_date,
      exp_zone_code,
      item_num,
      lookback_cond_code,
      lookback_last_date,
      opt_type,
      order_num,
      pay_term_code,
      premium,
      premium_curr_code,
      premium_pay_date,
      premium_uom_code,
      price_date_from,
      price_date_to,
      put_call_ind,
      resp_trans_id,
      settlement_type,
      strike_excer_date,
      strike_price,
      strike_price_curr_code,
      strike_price_uom_code,
      trade_num,
      trans_id
   from dbo.aud_trade_item_otc_opt
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemOtcOptRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemOtcOptRevPK', NULL, NULL
GO
