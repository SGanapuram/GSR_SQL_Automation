SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_classification]
(
   classification_code,
   classification_name,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.portfolio_tag_option with (nolock)
where tag_name = 'CLASS'
GO
GRANT SELECT ON  [dbo].[jms_classification] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_classification] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_classification', NULL, NULL
GO
