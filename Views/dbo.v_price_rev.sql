SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_price_rev]
(
   commkt_key,
   price_source_code,
   trading_prd,
   price_quote_date,
   low_bid_price,
   high_asked_price,
   avg_closed_price,
   open_interest,
   vol_traded,
   creation_type,
   low_bid_creation_ind,
   high_asked_creation_ind,
   avg_closed_creation_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   commkt_key,
   price_source_code,
   trading_prd,
   price_quote_date,
   low_bid_price,
   high_asked_price,
   avg_closed_price,
   open_interest,
   vol_traded,
   creation_type,
   low_bid_creation_ind,
   high_asked_creation_ind,
   avg_closed_creation_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_price
GO
GRANT SELECT ON  [dbo].[v_price_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_price_rev] TO [next_usr]
GO
