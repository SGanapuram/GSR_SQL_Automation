SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[posted_price_detail]
(
	 commodity,
	 source,
	 market,
	 effect_date,
	 posted_price,
	 gravity_table,
	 posted_gravity,
	 adjustment,
	 adj_price
)
as
select
   c.cmdty_code,
   p.price_source_code,
   c.mkt_code,
   p.price_quote_date,
   p.avg_closed_price,
   g.gravity_table_name,
   g.posted_gravity,
   0.0,
   p.avg_closed_price
from dbo.commodity_market c,
		 dbo.price p,
		 dbo.price_gravity_adj g
where c.commkt_key = p.commkt_key and
		  p.creation_type = 'P' and
		  g.commkt_key = p.commkt_key and
		  g.price_source_code = p.price_source_code and
		  g.price_quote_date = p.price_quote_date
GO
GRANT SELECT ON  [dbo].[posted_price_detail] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[posted_price_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'posted_price_detail', NULL, NULL
GO
