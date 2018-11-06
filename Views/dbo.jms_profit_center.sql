SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_profit_center]
(
   profit_center_code,
   profit_center_desc,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.portfolio_tag_option with (nolock)
where tag_name = 'PRFTCNTR'
GO
GRANT SELECT ON  [dbo].[jms_profit_center] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_profit_center] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_profit_center', NULL, NULL
GO
