SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxHedgeRateRevPK]
(
   @asof_trans_id          bigint,
   @fx_hedge_rate_num      int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.fx_hedge_rate
where fx_hedge_rate_num = @fx_hedge_rate_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      clr_brkr_num,
      commkt_key,
      conv_rate,
      from_curr_code,
      fx_hedge_rate_num,
      mul_div_ind,
      price_source_code,
      resp_trans_id = null,
      to_curr_code,
      trading_prd,
      trans_id
   from dbo.fx_hedge_rate
   where fx_hedge_rate_num = @fx_hedge_rate_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      clr_brkr_num,
      commkt_key,
      conv_rate,
      from_curr_code,
      fx_hedge_rate_num,
      mul_div_ind,
      price_source_code,
      resp_trans_id,
      to_curr_code,
      trading_prd,
      trans_id
   from dbo.aud_fx_hedge_rate
   where fx_hedge_rate_num = @fx_hedge_rate_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxHedgeRateRevPK] TO [next_usr]
GO
