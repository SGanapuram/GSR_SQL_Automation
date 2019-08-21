SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_commkt_info]
(
   commkt_key,
   cmdty_code,
   cmdty_short_name,
   cmdty_type,
   mkt_code,
   mkt_short_name,
   mkt_type,
   mtm_price_source_code
)
as
select
   cm.commkt_key,
   cm.cmdty_code,
   c.cmdty_short_name,
   c.cmdty_type,
   cm.mkt_code,
   m.mkt_short_name,
   m.mkt_type,
   cm.mtm_price_source_code
from dbo.commodity_market cm with (nolock)
        INNER JOIN dbo.commodity c with (nolock) 
           ON cm.cmdty_code = c.cmdty_code 
        INNER JOIN dbo.market m with (nolock) 
           ON cm.mkt_code = m.mkt_code 
GO
GRANT SELECT ON  [dbo].[v_TS_commkt_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_commkt_info] TO [next_usr]
GO
