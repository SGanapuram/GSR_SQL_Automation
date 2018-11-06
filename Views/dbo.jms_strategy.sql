SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_strategy]
(
   strategy_code,
   strategy_name,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.portfolio_tag_option with (nolock)
where tag_name = 'STRATEGY'
GO
GRANT SELECT ON  [dbo].[jms_strategy] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_strategy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_strategy', NULL, NULL
GO
