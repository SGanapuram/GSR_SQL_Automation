SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchParcelRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int

select @trans_id = trans_id
from dbo.parcel
where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
       alloc_item_num,
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
       resp_trans_id = null,
       sch_from_date,
       sch_qty,
       sch_qty_uom_code,
       sch_to_date,
       send_to_sap,
       shipment_num,
       status,
       t4_consignee,
       t4_loc,
       t4_tankage,
       tank_code,       
       tariff_code,
       trade_num,
       trans_id,
       transmitall_type,
       type
   from dbo.parcel
   where oid = @oid
end
else
begin
   set rowcount 1
   select
       alloc_item_num,
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
       t4_consignee,
       t4_loc,
       t4_tankage,
       tank_code,
       tariff_code,
       trade_num,
       trans_id,
       transmitall_type,
       type
   from dbo.aud_parcel
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchParcelRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchParcelRevPK', NULL, NULL
GO
