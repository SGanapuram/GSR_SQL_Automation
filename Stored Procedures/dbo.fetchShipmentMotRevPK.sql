SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchShipmentMotRevPK]
(
   @asof_trans_id      int,
   @mot_code           char(8),
   @shipment_num       int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.shipment_mot
where shipment_num = @shipment_num and
      mot_code = @mot_code
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      mot_code,
      resp_trans_id = null,
      shipment_num,
      trans_id
   from dbo.shipment_mot
   where shipment_num = @shipment_num and
         mot_code = @mot_code
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      mot_code,
      resp_trans_id,
      shipment_num,
      trans_id
   from dbo.aud_shipment_mot
   where shipment_num = @shipment_num and
         mot_code = @mot_code and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchShipmentMotRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchShipmentMotRevPK', NULL, NULL
GO
