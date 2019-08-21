SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_position_mark_to_market_rev]
(
   pos_num,
   mtm_asof_date,
   mtm_mkt_price,
   mtm_mkt_price_curr_code,
   mtm_mkt_price_uom_code,
   mtm_mkt_price_source_code,
   opt_eval_method,
   otc_opt_code,
   volatility,
   interest_rate,
   delta,
   gamma,
   theta,
   vega,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   pos_num,
   mtm_asof_date,
   mtm_mkt_price,
   mtm_mkt_price_curr_code,
   mtm_mkt_price_uom_code,
   mtm_mkt_price_source_code,
   opt_eval_method,
   otc_opt_code,
   volatility,
   interest_rate,
   delta,
   gamma,
   theta,
   vega,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_position_mark_to_market
GO
GRANT SELECT ON  [dbo].[v_position_mark_to_market_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_position_mark_to_market_rev] TO [next_usr]
GO
