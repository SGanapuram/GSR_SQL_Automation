SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_market_rev]
(
   mkt_code,
   mkt_type,
   mkt_status,
   mkt_short_name,
   mkt_full_name,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   mkt_code,
   mkt_type,
   mkt_status,
   mkt_short_name,
   mkt_full_name,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_market
GO
GRANT SELECT ON  [dbo].[v_market_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_market_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_market_rev', NULL, NULL
GO
