SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_ai_est_actual_all_rs]
(
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   ai_est_actual_date,
   ai_est_actual_gross_qty,
   ai_gross_qty_uom_code,
   ai_est_actual_net_qty,
   ai_net_qty_uom_code,
   ai_est_actual_short_cmnt,
   ai_est_actual_ind,
   ticket_num,
   lease_num,
   dest_trade_num,
   del_loc_code,
   scac_carrier_code,
   transporter_code,
   bol_code,
   owner_code,
   accum_num,
   secondary_actual_gross_qty,
   secondary_actual_net_qty,
   secondary_qty_uom_code,
   manual_input_sec_ind,
   fixed_swing_qty_ind,
   insert_sequence,
   mot_code,
   tertiary_gross_qty,
   tertiary_net_qty,
   tertiary_uom_code,
   actual_tax_mt_qty,
   actual_tax_m315_qty,
   start_load_date,
   stop_load_date,
   sap_position_num,
   assay_final_ind,
   actual_timezone,
   date_specs_recieved_from_al,
   unique_id,
   resp_trans_id,
   trans_id,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.alloc_num,
   maintb.alloc_item_num,
   maintb.ai_est_actual_num,
   maintb.ai_est_actual_date,
   maintb.ai_est_actual_gross_qty,
   maintb.ai_gross_qty_uom_code,
   maintb.ai_est_actual_net_qty,
   maintb.ai_net_qty_uom_code,
   maintb.ai_est_actual_short_cmnt,
   maintb.ai_est_actual_ind,
   maintb.ticket_num,
   maintb.lease_num,
   maintb.dest_trade_num,
   maintb.del_loc_code,
   maintb.scac_carrier_code,
   maintb.transporter_code,
   maintb.bol_code,
   maintb.owner_code,
   maintb.accum_num,
   maintb.secondary_actual_gross_qty,
   maintb.secondary_actual_net_qty,
   maintb.secondary_qty_uom_code,
   maintb.manual_input_sec_ind,
   maintb.fixed_swing_qty_ind,
   maintb.insert_sequence,
   maintb.mot_code,
   maintb.tertiary_gross_qty,
   maintb.tertiary_net_qty,
   maintb.tertiary_uom_code,
   maintb.actual_tax_mt_qty,
   maintb.actual_tax_m315_qty,
   maintb.start_load_date,
   maintb.stop_load_date,
   maintb.sap_position_num,
   maintb.assay_final_ind,
   maintb.actual_timezone,
   maintb.date_specs_recieved_from_al,
   maintb.unique_id,
   null,
   maintb.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.ai_est_actual maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.alloc_num,
   audtb.alloc_item_num,
   audtb.ai_est_actual_num,
   audtb.ai_est_actual_date,
   audtb.ai_est_actual_gross_qty,
   audtb.ai_gross_qty_uom_code,
   audtb.ai_est_actual_net_qty,
   audtb.ai_net_qty_uom_code,
   audtb.ai_est_actual_short_cmnt,
   audtb.ai_est_actual_ind,
   audtb.ticket_num,
   audtb.lease_num,
   audtb.dest_trade_num,
   audtb.del_loc_code,
   audtb.scac_carrier_code,
   audtb.transporter_code,
   audtb.bol_code,
   audtb.owner_code,
   audtb.accum_num,
   audtb.secondary_actual_gross_qty,
   audtb.secondary_actual_net_qty,
   audtb.secondary_qty_uom_code,
   audtb.manual_input_sec_ind,
   audtb.fixed_swing_qty_ind,
   audtb.insert_sequence,
   audtb.mot_code,
   audtb.tertiary_gross_qty,
   audtb.tertiary_net_qty,
   audtb.tertiary_uom_code,
   audtb.actual_tax_mt_qty,
   audtb.actual_tax_m315_qty,
   audtb.start_load_date,
   audtb.stop_load_date,
   audtb.sap_position_num,
   audtb.assay_final_ind,
   audtb.actual_timezone,
   audtb.date_specs_recieved_from_al,
   audtb.unique_id,
   audtb.resp_trans_id,
   audtb.trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_ai_est_actual audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ai_est_actual_all_rs] TO [next_usr]
GO
