SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchShipmentPathRevPK]
(
   @asof_trans_id      int,
   @shipment_oid       int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.shipment_path
where shipment_oid = @shipment_oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      path_oid,
      resp_trans_id = null,
      shipment_oid,
      trans_id
   from dbo.shipment_path
   where shipment_oid = @shipment_oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      path_oid,
      resp_trans_id,
      shipment_oid,
      trans_id
   from dbo.aud_shipment_path
   where shipment_oid = @shipment_oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchShipmentPathRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchShipmentPathRevPK', NULL, NULL
GO
