SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPositionMarkToMarketRevPK]
(
   @asof_trans_id      int,
   @mtm_asof_date      datetime,
   @pos_num            int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.position_mark_to_market
where pos_num = @pos_num and
      mtm_asof_date = @mtm_asof_date
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      delta,
      gamma,
      interest_rate,
      mtm_asof_date,
      mtm_mkt_price,
      mtm_mkt_price_curr_code,
      mtm_mkt_price_source_code,
      mtm_mkt_price_uom_code,
      opt_eval_method,
      otc_opt_code,
      pos_num,
      resp_trans_id = null,
      theta,
      trans_id,
      vega,
      volatility
   from dbo.position_mark_to_market
   where pos_num = @pos_num and
         mtm_asof_date = @mtm_asof_date
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      delta,
      gamma,
      interest_rate,
      mtm_asof_date,
      mtm_mkt_price,
      mtm_mkt_price_curr_code,
      mtm_mkt_price_source_code,
      mtm_mkt_price_uom_code,
      opt_eval_method,
      otc_opt_code,
      pos_num,
      resp_trans_id,
      theta,
      trans_id,
      vega,
      volatility
   from dbo.aud_position_mark_to_market
   where pos_num = @pos_num and
         mtm_asof_date = @mtm_asof_date and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPositionMarkToMarketRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchPositionMarkToMarketRevPK', NULL, NULL
GO
