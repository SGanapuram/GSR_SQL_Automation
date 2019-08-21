SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAllocItemTransportRevPK]
   @alloc_item_num      smallint,
   @alloc_num           int,
   @asof_trans_id       bigint
as
declare @trans_id           bigint

   select @trans_id = trans_id
   from dbo.allocation_item_transport
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num

if @trans_id <= @asof_trans_id
begin
   select
       alloc_item_num,
       alloc_num,
       asof_trans_id=@asof_trans_id,
       barge_name,
       bl_actual_ind,
       bl_date,
       bl_net_qty,
       bl_qty,
       bl_qty_gross_net_ind,
       bl_qty_uom_code,
       bl_sec_net_qty,
       bl_sec_qty,
       bl_sec_qty_uom_code,
       bl_ticket_num,
       customs_imp_exp_num,
       declaration_date,
       disch_cmnc_date,
       disch_compl_date,
       disch_net_qty,
       disch_qty,
       disch_qty_gross_net_ind,
       disch_qty_uom_code,
       disch_sec_net_qty,
       disch_sec_qty,
       disch_sec_qty_uom_code,
       eta_date,
       fsc_ind,
       hoses_connected_date,
       hoses_disconnected_date,
       lay_days_end_date,
       lay_days_start_date,
       load_cmnc_date,
       load_compl_date,
       load_disch_actual_ind,
       load_disch_date,
       load_disch_ticket_num,
       load_net_qty,
       load_qty,
       load_qty_gross_net_ind,
       load_qty_uom_code,
       load_sec_net_qty,
       load_sec_qty,
       load_sec_qty_uom_code,
       manual_input_sec_ind,
       negotiated_date,
	   nor_accp_date,
       nor_date,
       origin_country_code,
       parcel_num,
       pump_off_date,
       pump_on_date,
       resp_trans_id = null,
       tank_num,
       trans_id,
       transport_arrival_date,
       transport_depart_date,
       transportation,
       x_transportation
   from dbo.allocation_item_transport
   where alloc_num = @alloc_num and 
         alloc_item_num = @alloc_item_num
end
else
begin
   set rowcount 1
   select 
       alloc_item_num,
       alloc_num,
       asof_trans_id=@asof_trans_id,
       barge_name,
       bl_actual_ind,
       bl_date,
       bl_net_qty,
       bl_qty,
       bl_qty_gross_net_ind,
       bl_qty_uom_code,
       bl_sec_net_qty,
       bl_sec_qty,
       bl_sec_qty_uom_code,
       bl_ticket_num,
       customs_imp_exp_num,
       declaration_date,
       disch_cmnc_date,
       disch_compl_date,
       disch_net_qty,
       disch_qty,
       disch_qty_gross_net_ind,
       disch_qty_uom_code,
       disch_sec_net_qty,
       disch_sec_qty,
       disch_sec_qty_uom_code,
       eta_date,
       fsc_ind,
       hoses_connected_date,
       hoses_disconnected_date,
       lay_days_end_date,
       lay_days_start_date,
       load_cmnc_date,
       load_compl_date,
       load_disch_actual_ind,
       load_disch_date,
       load_disch_ticket_num,
       load_net_qty,
       load_qty,
       load_qty_gross_net_ind,
       load_qty_uom_code,
       load_sec_net_qty,
       load_sec_qty,
       load_sec_qty_uom_code,
       manual_input_sec_ind,
       negotiated_date,
	   nor_accp_date,
       nor_date,
       origin_country_code,
       parcel_num,
       pump_off_date,
       pump_on_date,
       resp_trans_id,
       tank_num,
       trans_id,
       transport_arrival_date,
       transport_depart_date,
       transportation,
       x_transportation
   from dbo.aud_allocation_item_transport
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAllocItemTransportRevPK] TO [next_usr]
GO
