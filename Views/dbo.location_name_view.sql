SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[location_name_view] 
(
   loc_name
)
as
select loc_name 
from dbo.location
GO
GRANT SELECT ON  [dbo].[location_name_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[location_name_view] TO [next_usr]
GO
