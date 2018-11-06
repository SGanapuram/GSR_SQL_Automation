SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
create view [dbo].[v_ai_transport_rs]
(
   alloc_num,
   alloc_item_num,
   transportation,
   parcel_num,
   x_transportation,
   barge_name,
   fsc_ind,
   lay_days_start_date,
   lay_days_end_date,
   eta_date,
   bl_date,
   nor_date,
   load_cmnc_date,
   load_compl_date,
   disch_cmnc_date,
   disch_compl_date,
   bl_qty,
   bl_qty_uom_code,
   bl_qty_gross_net_ind,
   load_qty,
   load_qty_uom_code,
   load_qty_gross_net_ind,
   disch_qty,
   disch_qty_uom_code,
   disch_qty_gross_net_ind,
   pump_on_date,
   pump_off_date,
   bl_actual_ind,
   bl_ticket_num,
   load_disch_actual_ind,
   load_disch_ticket_num,
   load_disch_date,
   hoses_disconnected_date,
   bl_sec_qty,
   load_sec_qty,
   disch_sec_qty,
   bl_sec_qty_uom_code,
   load_sec_qty_uom_code,
   disch_sec_qty_uom_code,
   origin_country_code,
   manual_input_sec_ind,
   load_net_qty,
   disch_net_qty,
   bl_net_qty,
   load_sec_net_qty,
   disch_sec_net_qty,
   bl_sec_net_qty,
   customs_imp_exp_num,
   declaration_date,
   tank_num,
   transport_arrival_date,
   transport_depart_date,
   hoses_connected_date,
   negotiated_date,
   nor_accp_date,
   trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name
)
as
select
   maintb.alloc_num,
   maintb.alloc_item_num,
   maintb.transportation,
   maintb.parcel_num,
   maintb.x_transportation,
   maintb.barge_name,
   maintb.fsc_ind,
   maintb.lay_days_start_date,
   maintb.lay_days_end_date,
   maintb.eta_date,
   maintb.bl_date,
   maintb.nor_date,
   maintb.load_cmnc_date,
   maintb.load_compl_date,
   maintb.disch_cmnc_date,
   maintb.disch_compl_date,
   maintb.bl_qty,
   maintb.bl_qty_uom_code,
   maintb.bl_qty_gross_net_ind,
   maintb.load_qty,
   maintb.load_qty_uom_code,
   maintb.load_qty_gross_net_ind,
   maintb.disch_qty,
   maintb.disch_qty_uom_code,
   maintb.disch_qty_gross_net_ind,
   maintb.pump_on_date,
   maintb.pump_off_date,
   maintb.bl_actual_ind,
   maintb.bl_ticket_num,
   maintb.load_disch_actual_ind,
   maintb.load_disch_ticket_num,
   maintb.load_disch_date,
   maintb.hoses_disconnected_date,
   maintb.bl_sec_qty,
   maintb.load_sec_qty,
   maintb.disch_sec_qty,
   maintb.bl_sec_qty_uom_code,
   maintb.load_sec_qty_uom_code,
   maintb.disch_sec_qty_uom_code,
   maintb.origin_country_code,
   maintb.manual_input_sec_ind,
   maintb.load_net_qty,
   maintb.disch_net_qty,
   maintb.bl_net_qty,
   maintb.load_sec_net_qty,
   maintb.disch_sec_net_qty,
   maintb.bl_sec_net_qty,
   maintb.customs_imp_exp_num,
   maintb.declaration_date,
   maintb.tank_num,
   maintb.transport_arrival_date,
   maintb.transport_depart_date,
   maintb.hoses_connected_date,
   maintb.negotiated_date,
   maintb.nor_accp_date,
   maintb.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name
from dbo.allocation_item_transport maintb
    left outer join dbo.icts_transaction it
        on maintb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ai_transport_rs] TO [next_usr]
GO
