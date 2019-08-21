SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_VAR_commkt_info]
(
   commkt_key,
   cmdty_code,
   cmdty_short_name,
   cmdty_type,
   mkt_code,
   mkt_short_name,
   mkt_type,
   mtm_price_source_code,
   phy_commkt_curr_code, 
   phy_commkt_price_uom_code,
   phy_sec_price_source_code, 
   fut_commkt_curr_code, 
   fut_commkt_price_uom_code, 
   fut_sec_price_source_code
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
   cm.mtm_price_source_code,
   cp.commkt_curr_code, 
   cp.commkt_price_uom_code,
   cp.sec_price_source_code, 
   cf.commkt_curr_code, 
   cf.commkt_price_uom_code, 
   cf.sec_price_source_code
from dbo.commodity_market cm with (nolock)
        INNER JOIN dbo.commodity c with (nolock) 
           ON cm.cmdty_code = c.cmdty_code 
        INNER JOIN dbo.market m with (nolock) 
           ON cm.mkt_code = m.mkt_code 
        LEFT OUTER JOIN dbo.commkt_physical_attr cp with (nolock)
           ON cm.commkt_key = cp.commkt_key 
        LEFT OUTER JOIN dbo.commkt_future_attr cf with (nolock)
           ON cm.commkt_key = cf.commkt_key 
GO
GRANT SELECT ON  [dbo].[v_VAR_commkt_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_commkt_info] TO [next_usr]
GO
