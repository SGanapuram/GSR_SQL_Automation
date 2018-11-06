SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_groups]
(
   group_code,
   group_desc,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.portfolio_tag_option with (nolock)
where tag_name = 'GROUP'
GO
GRANT SELECT ON  [dbo].[jms_groups] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_groups] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_groups', NULL, NULL
GO
