SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[markets_attached] 
(
	 mkt_code, 
	 mkt_short_name,
	 commkt_key,
	 cmdty_code,
	 cmdty_short_name
)
as
select	
   m.mkt_code, 
   m.mkt_short_name,
   cm.commkt_key,
   cm.cmdty_code,
   c.cmdty_short_name		
from dbo.market m, 
     dbo.commodity_market cm, 
     dbo.commodity c
where m.mkt_code = cm.mkt_code and
      cm.cmdty_code = c.cmdty_code and 
      m.mkt_status in ('A', 'N')
GO
GRANT SELECT ON  [dbo].[markets_attached] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[markets_attached] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'markets_attached', NULL, NULL
GO
