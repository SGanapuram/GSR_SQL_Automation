SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_mkt_pricing_cond_rev]
(
   cmf_num,
   mkt_pricing_cond_num,
   mkt_cond_type,
   mkt_cond_date,
   mkt_cond_quote_range,
   mkt_cond_last_next_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   cmf_num,
   mkt_pricing_cond_num,
   mkt_cond_type,
   mkt_cond_date,
   mkt_cond_quote_range,
   mkt_cond_last_next_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_market_pricing_condition
GO
GRANT SELECT ON  [dbo].[v_mkt_pricing_cond_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_mkt_pricing_cond_rev] TO [next_usr]
GO
