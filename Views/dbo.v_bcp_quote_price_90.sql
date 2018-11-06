SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_quote_price_90]
as 
select *
from dbo.quote_price c
where exists (select 1
              from dbo.v_bcp_icts_transaction_90 t
              where c.trans_id = t.trans_id)
GO
GRANT SELECT ON  [dbo].[v_bcp_quote_price_90] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_quote_price_90] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_quote_price_90', NULL, NULL
GO
