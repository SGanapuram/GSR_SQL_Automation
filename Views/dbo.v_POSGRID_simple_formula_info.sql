SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_simple_formula_info]
(
	 simple_formula_num,
	 quote_commkt_key,
	 quote_trading_prd,
	 quote_price_source_code,
	 quote_diff,
	 quote_price_type,
   commkt_key,
   cmdty_code,
   cmdty_short_name,
   mkt_code,
   mkt_short_name,
   mtm_price_source_code,
   commkt_price_uom_code
)
as
select
	 sf.simple_formula_num,
	 sf.quote_commkt_key,
	 sf.quote_trading_prd,
	 sf.quote_price_source_code,
	 sf.quote_diff,
	 sf.quote_price_type,
   cm.commkt_key,
   cm.cmdty_code,
   cm.cmdty_short_name,
   cm.mkt_code,
   cm.mkt_short_name,
   cm.mtm_price_source_code,
   cm.commkt_price_uom_code	 
from dbo.simple_formula sf with (nolock)
        INNER JOIN dbo.v_POSGRID_commkt_info cm
            ON sf.quote_commkt_key = cm.commkt_key
GO
GRANT SELECT ON  [dbo].[v_POSGRID_simple_formula_info] TO [next_usr]
GO
