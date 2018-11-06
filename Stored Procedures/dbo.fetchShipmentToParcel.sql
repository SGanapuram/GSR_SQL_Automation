SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchShipmentToParcel]
(
   @asof_trans_id       int,
   @shipment_num        int
)
as
set nocount on

   select alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,                   
          associative_state,
          bookco_bank_acct_num,
          cmdty_code,
          cmnt_num,
          creation_date,
          creator_init,
          custom_code,
          custom_status,
          estimated_date,
          excise_status,
          facility_code,
          forecast_num,
          gn_taric_code,
          grade,
          inspector,
          inv_num,
          item_num,
          last_update_by_init,
          last_update_date,
          latest_feed_name,
          location_code,
          mot_type_code,
          nomin_qty,
          nomin_qty_uom_code,
          oid,
          order_num,
          product_code,
          quality,
          reference,
          resp_trans_id = NULL,
          sch_from_date,
          sch_qty,
          sch_qty_uom_code,
          sch_to_date,
          send_to_sap,
          shipment_num,
          status,
          t4_loc,
          t4_consignee,
          t4_tankage,
          tank_code,
          tariff_code,
          trade_num,
          trans_id,
          transmitall_type,
          type
   from dbo.parcel
   where shipment_num = @shipment_num and 
         trans_id <= @asof_trans_id
   union
   select alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,                   
          associative_state,
          bookco_bank_acct_num,
          cmdty_code,
          cmnt_num,
          creation_date,
          creator_init,
          custom_code,
          custom_status,
          estimated_date,
          excise_status,
          facility_code,
          forecast_num,
          gn_taric_code,
          grade,
          inspector,
          inv_num,
          item_num,
          last_update_by_init,
          last_update_date,
          latest_feed_name,
          location_code,
          mot_type_code,
          nomin_qty,
          nomin_qty_uom_code,
          oid,
          order_num,
          product_code,
          quality,
          reference,
          resp_trans_id,
          sch_from_date,
          sch_qty,
          sch_qty_uom_code,
          sch_to_date,
          send_to_sap,
          shipment_num,
          status,
          t4_loc,
          t4_consignee,
          t4_tankage,
          tank_code,
          tariff_code,
          trade_num,
          trans_id,
          transmitall_type,
          type
   from dbo.aud_parcel
   where shipment_num = @shipment_num and 
         (trans_id <= @asof_trans_id and 
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchShipmentToParcel] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchShipmentToParcel', NULL, NULL
GO
