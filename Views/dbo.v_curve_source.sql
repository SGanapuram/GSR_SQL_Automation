SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_curve_source]
(
	 commkt_key,
	 alias_source_code,
	 commkt_alias_name
)
as
select
	 commkt_key,
	 alias_source_code,
	 commkt_alias_name
from dbo.commodity_market_alias with (nolock)
where alias_source_code = 'CURVESRC' 
GO
GRANT SELECT ON  [dbo].[v_curve_source] TO [next_usr]
GO
