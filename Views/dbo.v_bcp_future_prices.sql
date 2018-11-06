SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_future_prices]
as 
select * 
from dbo.price
where datepart(yy, price_quote_date) > datepart(yy, getdate())
GO
GRANT SELECT ON  [dbo].[v_bcp_future_prices] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_future_prices] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_future_prices', NULL, NULL
GO
