SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchInventoryToAllocItem]
(
   @asof_trans_id      bigint,
   @inv_num            int
)
as
set nocount on
 
   select acct_num,
          acct_ref_num,
          actual_gross_qty,
          actual_gross_uom_code,
          alloc_item_confirm,
          alloc_item_num,
          alloc_item_short_cmnt,
          alloc_item_status,
          alloc_item_type,
          alloc_item_verify,
          alloc_num,
          ar_alloc_item_num,
          ar_alloc_num,
          asof_trans_id = @asof_trans_id,
          auto_receipt_actual_ind,
          auto_receipt_ind,
          auto_sampling_comp_num,
          auto_sampling_ind,
          cmdty_code,
          cmnt_num,
          confirmation_date,
          cr_anly_init,
          cr_clear_ind,
          credit_term_code,
          del_term_code,
          dest_loc_code,
          estimate_event_date,
          final_dest_loc_code,
          finance_bank_num,
          fully_actualized,
          imp_rec_ind,
          imp_rec_reason_oid,
          insp_acct_num,
          inspection_date,
          inspector_percent,
          inv_num,
          item_num,
          lc_num,
          load_port_loc_code,
          max_ai_est_actual_num,
          net_nom_num,
          nomin_date_from,
          nomin_date_to,
          nomin_qty_max,
          nomin_qty_max_uom_code,
          nomin_qty_min,
          nomin_qty_min_uom_code,
          order_num,
          origin_loc_code,
          pay_days,
          pay_term_code,
          purchasing_group,
          recap_item_num,
          reporting_date,
          resp_trans_id = NULL,
          sap_delivery_line_item_num,
          sap_delivery_num,
          sch_qty,
          sch_qty_periodicity,
          sch_qty_uom_code,
          sec_actual_uom_code,
          secondary_actual_qty,
          ship_agent_comp_num,
          ship_broker_comp_num,
          sub_alloc_num,
          title_tran_date,
          title_tran_loc_code,
          trade_num,
          trans_id,
          transfer_price,
          transfer_price_curr_code,
          transfer_price_curr_code_to,
	        transfer_price_currency_rate,
          transfer_price_uom_code,
          vat_ind
   from dbo.allocation_item
   where inv_num = @inv_num and
         trans_id <= @asof_trans_id
   union
   select acct_num,
          acct_ref_num,
          actual_gross_qty,
          actual_gross_uom_code,
          alloc_item_confirm,
          alloc_item_num,
          alloc_item_short_cmnt,
          alloc_item_status,
          alloc_item_type,
          alloc_item_verify,
          alloc_num,
          ar_alloc_item_num,
          ar_alloc_num,
          asof_trans_id = @asof_trans_id,
          auto_receipt_actual_ind,
          auto_receipt_ind,
          auto_sampling_comp_num,
          auto_sampling_ind,
          cmdty_code,
          cmnt_num,
          confirmation_date,
          cr_anly_init,
          cr_clear_ind,
          credit_term_code,
          del_term_code,
          dest_loc_code,
          estimate_event_date,
          final_dest_loc_code,
          finance_bank_num,
          fully_actualized,
          imp_rec_ind,
          imp_rec_reason_oid,
          insp_acct_num,
          inspection_date,
          inspector_percent,
          inv_num,
          item_num,
          lc_num,
          load_port_loc_code,
          max_ai_est_actual_num,
          net_nom_num,
          nomin_date_from,
          nomin_date_to,
          nomin_qty_max,
          nomin_qty_max_uom_code,
          nomin_qty_min,
          nomin_qty_min_uom_code,
          order_num,
          origin_loc_code,
          pay_days,
          pay_term_code,
          purchasing_group,
          recap_item_num,
          reporting_date,
          resp_trans_id,
          sap_delivery_line_item_num,
          sap_delivery_num,
          sch_qty,
          sch_qty_periodicity,
          sch_qty_uom_code,
          sec_actual_uom_code,
          secondary_actual_qty,
          ship_agent_comp_num,
          ship_broker_comp_num,
          sub_alloc_num,
          title_tran_date,
          title_tran_loc_code,
          trade_num,
          trans_id,
          transfer_price,
          transfer_price_curr_code,
          transfer_price_curr_code_to,
	        transfer_price_currency_rate,
          transfer_price_uom_code,
          vat_ind
   from dbo.aud_allocation_item
   where inv_num = @inv_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchInventoryToAllocItem] TO [next_usr]
GO
