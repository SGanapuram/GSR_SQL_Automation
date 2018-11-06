SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[currency_commodity]
(
	 cmdty_code, 
	 cmdty_short_name, 
	 cmdty_full_name
)
as
select 
   cmdty_code, 
   cmdty_short_name, 
   cmdty_full_name 
from dbo.commodity
where cmdty_type = 'C'
GO
GRANT SELECT ON  [dbo].[currency_commodity] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[currency_commodity] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'currency_commodity', NULL, NULL
GO
