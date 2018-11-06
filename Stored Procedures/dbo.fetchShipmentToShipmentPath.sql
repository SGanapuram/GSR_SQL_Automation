SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchShipmentToShipmentPath]
(
   @asof_trans_id      int,
   @shipment_num       int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          path_oid,
          resp_trans_id = NULL,
          shipment_oid,
          trans_id
   from dbo.shipment_path
   where shipment_oid = @shipment_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          path_oid,
          resp_trans_id,
          shipment_oid,
          trans_id
   from dbo.aud_shipment_path
   where shipment_oid = @shipment_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchShipmentToShipmentPath] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchShipmentToShipmentPath', NULL, NULL
GO
