SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_location]
(
   location_code,
   location_name,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.portfolio_tag_option with (nolock)
where tag_name = 'LOCATION'
GO
GRANT SELECT ON  [dbo].[jms_location] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_location] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_location', NULL, NULL
GO
