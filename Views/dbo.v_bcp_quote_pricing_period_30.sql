SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_quote_pricing_period_30]
as 
select *
from dbo.quote_pricing_period c
where exists (select 1
              from dbo.v_bcp_icts_transaction_30 t
              where c.trans_id = t.trans_id)
GO
GRANT SELECT ON  [dbo].[v_bcp_quote_pricing_period_30] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_quote_pricing_period_30] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_quote_pricing_period_30', NULL, NULL
GO