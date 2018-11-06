SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_shipment_all_rs]
(
   oid,
   status,
   reference,
   primary_shipment_num,
   alloc_num,
   mot_type_code,
   capacity,
   capacity_uom_code,
   ship_qty,
   ship_qty_uom_code,
   cmdty_code,
   start_loc_code,
   end_loc_code,
   start_date,
   end_date,
   transport_owner_id,
   transport_operator_id,
   pipeline_cycle_num,
   freight_rate,
   freight_rate_uom_code,
   freight_rate_curr_code,
   freight_pay_term_code,
   contract_num,
   creator_init,
   creation_date,
   last_update_by_init,
   last_update_date,
   trans_id,
   resp_trans_id,
   transport_reference,
   cmnt_num,
   load_facility_code,
   load_tank_num,
   dest_facility_code,
   dest_tank_num,
   contract_order_num,
   manual_transport_parcels,
   feed_interface,
   balance_qty,
   sap_shipment_num,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.oid,
   maintb.status,
   maintb.reference,
   maintb.primary_shipment_num,
   maintb.alloc_num,
   maintb.mot_type_code,
   maintb.capacity,
   maintb.capacity_uom_code,
   maintb.ship_qty,
   maintb.ship_qty_uom_code,
   maintb.cmdty_code,
   maintb.start_loc_code,
   maintb.end_loc_code,
   maintb.start_date,
   maintb.end_date,
   maintb.transport_owner_id,
   maintb.transport_operator_id,
   maintb.pipeline_cycle_num,
   maintb.freight_rate,
   maintb.freight_rate_uom_code,
   maintb.freight_rate_curr_code,
   maintb.freight_pay_term_code,
   maintb.contract_num,
   maintb.creator_init,
   maintb.creation_date,
   maintb.last_update_by_init,
   maintb.last_update_date,
   maintb.trans_id,
   null,
   maintb.transport_reference,
   maintb.cmnt_num,
   maintb.load_facility_code,
   maintb.load_tank_num,
   maintb.dest_facility_code,
   maintb.dest_tank_num,
   maintb.contract_order_num,
   maintb.manual_transport_parcels,
   maintb.feed_interface,
   maintb.balance_qty,
   maintb.sap_shipment_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.shipment maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.oid,
   audtb.status,
   audtb.reference,
   audtb.primary_shipment_num,
   audtb.alloc_num,
   audtb.mot_type_code,
   audtb.capacity,
   audtb.capacity_uom_code,
   audtb.ship_qty,
   audtb.ship_qty_uom_code,
   audtb.cmdty_code,
   audtb.start_loc_code,
   audtb.end_loc_code,
   audtb.start_date,
   audtb.end_date,
   audtb.transport_owner_id,
   audtb.transport_operator_id,
   audtb.pipeline_cycle_num,
   audtb.freight_rate,
   audtb.freight_rate_uom_code,
   audtb.freight_rate_curr_code,
   audtb.freight_pay_term_code,
   audtb.contract_num,
   audtb.creator_init,
   audtb.creation_date,
   audtb.last_update_by_init,
   audtb.last_update_date,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.transport_reference,
   audtb.cmnt_num,
   audtb.load_facility_code,
   audtb.load_tank_num,
   audtb.dest_facility_code,
   audtb.dest_tank_num,
   audtb.contract_order_num,
   audtb.manual_transport_parcels,
   audtb.feed_interface,
   audtb.balance_qty,
   audtb.sap_shipment_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_shipment audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_shipment_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_shipment_all_rs] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_shipment_all_rs', NULL, NULL
GO
