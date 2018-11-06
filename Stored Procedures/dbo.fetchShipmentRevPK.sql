SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchShipmentRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.shipment
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      alloc_num,
      asof_trans_id = @asof_trans_id,
      balance_qty,
      capacity,
      capacity_uom_code,
      cmdty_code,
      cmnt_num,
      contract_num,
      contract_order_num,
      creation_date,
      creator_init,
      dest_facility_code,
      dest_tank_num,
      end_date,
      end_loc_code,
      feed_interface,
      freight_pay_term_code,
      freight_rate,
      freight_rate_curr_code,
      freight_rate_uom_code,
      last_update_by_init,
      last_update_date,
      load_facility_code,
      load_tank_num,
      manual_transport_parcels,
      mot_type_code,
      oid,
      pipeline_cycle_num,
      primary_shipment_num,
      reference,
      resp_trans_id = null,
      sap_shipment_num,
      ship_qty,
      ship_qty_uom_code,
      start_date,
      start_loc_code,
      status,
      trans_id,
      transport_operator_id,
      transport_owner_id,
      transport_reference
   from dbo.shipment
   where oid = @oid
end
else
begin
   select top 1
      alloc_num,
      asof_trans_id = @asof_trans_id,
      balance_qty,
      capacity,
      capacity_uom_code,
      cmdty_code,
      cmnt_num,
      contract_num,
      contract_order_num,
      creation_date,
      creator_init,
      dest_facility_code,
      dest_tank_num,
      end_date,
      end_loc_code,
      feed_interface,
      freight_pay_term_code,
      freight_rate,
      freight_rate_curr_code,
      freight_rate_uom_code,
      last_update_by_init,
      last_update_date,
      load_facility_code,
      load_tank_num,
      manual_transport_parcels,
      mot_type_code,
      oid,
      pipeline_cycle_num,
      primary_shipment_num,
      reference,
      resp_trans_id,
      sap_shipment_num,
      ship_qty,
      ship_qty_uom_code,
      start_date,
      start_loc_code,
      status,
      trans_id,
      transport_operator_id,
      transport_owner_id,
      transport_reference
   from dbo.aud_shipment
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchShipmentRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchShipmentRevPK', NULL, NULL
GO
