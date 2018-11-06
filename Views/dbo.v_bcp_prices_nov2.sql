SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_prices_nov2]
as
select *
from dbo.price
where datepart(mm, price_quote_date) = 11 and
      datepart(yy, price_quote_date) = datepart(yy, getdate())
GO
GRANT SELECT ON  [dbo].[v_bcp_prices_nov2] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_prices_nov2] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_prices_nov2', NULL, NULL
GO