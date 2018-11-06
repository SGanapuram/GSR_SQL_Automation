SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_mkt_price_quo_dates_rev]
(
   cmf_num,
   calendar_date,
   quote_date,
   priced_ind,
   end_of_period_ind,
   fiscal_month,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   cmf_num,
   calendar_date,
   quote_date,
   priced_ind,
   end_of_period_ind,
   fiscal_month,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_market_price_quote_dates
GO
GRANT SELECT ON  [dbo].[v_mkt_price_quo_dates_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_mkt_price_quo_dates_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_mkt_price_quo_dates_rev', NULL, NULL
GO
