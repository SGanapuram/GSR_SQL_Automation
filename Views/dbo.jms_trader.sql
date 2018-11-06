SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_trader]
(
   trader_init,
   trader_name,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.portfolio_tag_option with (nolock)
where tag_name = 'TRADER'
GO
GRANT SELECT ON  [dbo].[jms_trader] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_trader] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_trader', NULL, NULL
GO
