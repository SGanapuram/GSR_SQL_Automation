SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_allocation_item_all_rs]
(
   alloc_num,
   alloc_item_num,
   alloc_item_type,
   alloc_item_status,
   sub_alloc_num,
   trade_num,
   order_num,
   item_num,
   acct_num,
   cmdty_code,
   sch_qty,
   sch_qty_uom_code,
   nomin_date_from,
   nomin_date_to,
   nomin_qty_min,
   nomin_qty_min_uom_code,
   nomin_qty_max,
   nomin_qty_max_uom_code,
   title_tran_loc_code,
   title_tran_date,
   origin_loc_code,
   dest_loc_code,
   credit_term_code,
   pay_term_code,
   pay_days,
   del_term_code,
   cr_clear_ind,
   cr_anly_init,
   alloc_item_short_cmnt,
   cmnt_num,
   alloc_item_confirm,
   alloc_item_verify,
   sch_qty_periodicity,
   auto_receipt_ind,
   actual_gross_qty,
   actual_gross_uom_code,
   fully_actualized,
   ar_alloc_num,
   ar_alloc_item_num,
   inv_num,
   insp_acct_num,
   confirmation_date,
   net_nom_num,
   recap_item_num,
   auto_receipt_actual_ind,
   acct_ref_num,
   final_dest_loc_code,
   lc_num,
   reporting_date,
   max_ai_est_actual_num,
   inspection_date,
   inspector_percent,
   auto_sampling_ind,
   auto_sampling_comp_num,
   ship_agent_comp_num,
   ship_broker_comp_num,
   secondary_actual_qty,
   load_port_loc_code,
   sec_actual_uom_code,
   purchasing_group,
   trans_id,
   resp_trans_id,
   vat_ind,
   imp_rec_ind,
   imp_rec_reason_oid,
   estimate_event_date,
   finance_bank_num,
   sap_delivery_num,
   sap_delivery_line_item_num,
   transfer_price,
   transfer_price_uom_code,
   transfer_price_curr_code,
   transfer_price_curr_code_to,
	 transfer_price_currency_rate,
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
   maintb.alloc_item_type,
   maintb.alloc_item_status,
   maintb.sub_alloc_num,
   maintb.trade_num,
   maintb.order_num,
   maintb.item_num,
   maintb.acct_num,
   maintb.cmdty_code,
   maintb.sch_qty,
   maintb.sch_qty_uom_code,
   maintb.nomin_date_from,
   maintb.nomin_date_to,
   maintb.nomin_qty_min,
   maintb.nomin_qty_min_uom_code,
   maintb.nomin_qty_max,
   maintb.nomin_qty_max_uom_code,
   maintb.title_tran_loc_code,
   maintb.title_tran_date,
   maintb.origin_loc_code,
   maintb.dest_loc_code,
   maintb.credit_term_code,
   maintb.pay_term_code,
   maintb.pay_days,
   maintb.del_term_code,
   maintb.cr_clear_ind,
   maintb.cr_anly_init,
   maintb.alloc_item_short_cmnt,
   maintb.cmnt_num,
   maintb.alloc_item_confirm,
   maintb.alloc_item_verify,
   maintb.sch_qty_periodicity,
   maintb.auto_receipt_ind,
   maintb.actual_gross_qty,
   maintb.actual_gross_uom_code,
   maintb.fully_actualized,
   maintb.ar_alloc_num,
   maintb.ar_alloc_item_num,
   maintb.inv_num,
   maintb.insp_acct_num,
   maintb.confirmation_date,
   maintb.net_nom_num,
   maintb.recap_item_num,
   maintb.auto_receipt_actual_ind,
   maintb.acct_ref_num,
   maintb.final_dest_loc_code,
   maintb.lc_num,
   maintb.reporting_date,
   maintb.max_ai_est_actual_num,
   maintb.inspection_date,
   maintb.inspector_percent,
   maintb.auto_sampling_ind,
   maintb.auto_sampling_comp_num,
   maintb.ship_agent_comp_num,
   maintb.ship_broker_comp_num,
   maintb.secondary_actual_qty,
   maintb.load_port_loc_code,
   maintb.sec_actual_uom_code,
   maintb.purchasing_group,
   maintb.trans_id,
   null,
   maintb.vat_ind,
   maintb.imp_rec_ind,
   maintb.imp_rec_reason_oid,
   maintb.estimate_event_date,
   maintb.finance_bank_num,
   maintb.sap_delivery_num,
   maintb.sap_delivery_line_item_num,
   maintb.transfer_price,
   maintb.transfer_price_uom_code,
   maintb.transfer_price_curr_code,
   maintb.transfer_price_curr_code_to,
   maintb.transfer_price_currency_rate,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.allocation_item maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.alloc_num,
   audtb.alloc_item_num,
   audtb.alloc_item_type,
   audtb.alloc_item_status,
   audtb.sub_alloc_num,
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.acct_num,
   audtb.cmdty_code,
   audtb.sch_qty,
   audtb.sch_qty_uom_code,
   audtb.nomin_date_from,
   audtb.nomin_date_to,
   audtb.nomin_qty_min,
   audtb.nomin_qty_min_uom_code,
   audtb.nomin_qty_max,
   audtb.nomin_qty_max_uom_code,
   audtb.title_tran_loc_code,
   audtb.title_tran_date,
   audtb.origin_loc_code,
   audtb.dest_loc_code,
   audtb.credit_term_code,
   audtb.pay_term_code,
   audtb.pay_days,
   audtb.del_term_code,
   audtb.cr_clear_ind,
   audtb.cr_anly_init,
   audtb.alloc_item_short_cmnt,
   audtb.cmnt_num,
   audtb.alloc_item_confirm,
   audtb.alloc_item_verify,
   audtb.sch_qty_periodicity,
   audtb.auto_receipt_ind,
   audtb.actual_gross_qty,
   audtb.actual_gross_uom_code,
   audtb.fully_actualized,
   audtb.ar_alloc_num,
   audtb.ar_alloc_item_num,
   audtb.inv_num,
   audtb.insp_acct_num,
   audtb.confirmation_date,
   audtb.net_nom_num,
   audtb.recap_item_num,
   audtb.auto_receipt_actual_ind,
   audtb.acct_ref_num,
   audtb.final_dest_loc_code,
   audtb.lc_num,
   audtb.reporting_date,
   audtb.max_ai_est_actual_num,
   audtb.inspection_date,
   audtb.inspector_percent,
   audtb.auto_sampling_ind,
   audtb.auto_sampling_comp_num,
   audtb.ship_agent_comp_num,
   audtb.ship_broker_comp_num,
   audtb.secondary_actual_qty,
   audtb.load_port_loc_code,
   audtb.sec_actual_uom_code,
   audtb.purchasing_group,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.vat_ind,
   audtb.imp_rec_ind,
   audtb.imp_rec_reason_oid,
   audtb.estimate_event_date,
   audtb.finance_bank_num,
   audtb.sap_delivery_num,
   audtb.sap_delivery_line_item_num,
   audtb.transfer_price,
   audtb.transfer_price_uom_code,
   audtb.transfer_price_curr_code,
   audtb.transfer_price_curr_code_to,
   audtb.transfer_price_currency_rate,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_allocation_item audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_allocation_item_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_allocation_item_all_rs] TO [next_usr]
GO
