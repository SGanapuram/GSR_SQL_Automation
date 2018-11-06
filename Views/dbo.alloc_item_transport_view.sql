SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[alloc_item_transport_view]
(
	 parcel_num,
   trans_id
)
as
select
   parcel_num,
   trans_id
from dbo.allocation_detail
GO
GRANT SELECT ON  [dbo].[alloc_item_transport_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[alloc_item_transport_view] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'alloc_item_transport_view', NULL, NULL
GO
