SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_commkt_info]
(
   commkt_key,
   cmdty_code,
   cmdty_short_name,
   cmdty_type,
   mkt_code,
   mkt_short_name,
   mkt_type,
   mtm_price_source_code,
   commkt_price_uom_code,
   commkt_curr_code,
   commkt_lot_size
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
   isnull(cpa.commkt_price_uom_code, isnull(cfa.commkt_price_uom_code, coa.commkt_price_uom_code)),          
   isnull(cpa.commkt_curr_code, isnull(cfa.commkt_curr_code, coa.commkt_curr_code)),          
   isnull(cfa.commkt_lot_size, coa.commkt_lot_size)          
from dbo.commodity_market cm with (nolock)
        INNER JOIN dbo.commodity c with (nolock) 
           ON cm.cmdty_code = c.cmdty_code 
        INNER JOIN dbo.market m with (nolock) 
           ON cm.mkt_code = m.mkt_code 
        LEFT OUTER JOIN dbo.commkt_physical_attr cpa with (nolock) 
           ON cm.commkt_key = cpa.commkt_key
        LEFT OUTER JOIN dbo.commkt_future_attr cfa with (nolock) 
           ON cm.commkt_key = cfa.commkt_key 
        LEFT OUTER JOIN dbo.commkt_option_attr coa with (nolock) 
           on cm.commkt_key = coa.commkt_key          
GO
GRANT SELECT ON  [dbo].[v_POSGRID_commkt_info] TO [next_usr]
GO
