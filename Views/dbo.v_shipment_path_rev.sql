SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_shipment_path_rev]
(
   shipment_oid,
   path_oid,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   shipment_oid,
   path_oid,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_shipment_path
GO
GRANT SELECT ON  [dbo].[v_shipment_path_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_shipment_path_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_shipment_path_rev', NULL, NULL
GO
