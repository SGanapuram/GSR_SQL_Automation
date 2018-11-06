SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[commoditys_attached]
(
	 cmdty_code, 
	 cmdty_short_name,
	 commkt_key,
	 mkt_code,
	 mkt_short_name
)
as
select	
   c.cmdty_code, 
   c.cmdty_short_name,
   cm.commkt_key,
   cm.mkt_code,
   m.mkt_short_name
from dbo.commodity c, 
     dbo.commodity_market cm, 
     dbo.market m
where c.cmdty_code = cm.cmdty_code and
      cm.mkt_code = m.mkt_code and
      c.cmdty_status in ('A', 'N')
GO
GRANT SELECT ON  [dbo].[commoditys_attached] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[commoditys_attached] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'commoditys_attached', NULL, NULL
GO
