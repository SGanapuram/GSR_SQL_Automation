SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_allocation_rev]
(
   alloc_num,
   alloc_type_code,
   mot_code,
   sch_init,
   alloc_status,
   cmnt_num,
   ppl_comp_num,
   ppl_comp_cont_num,
   sch_prd,
   ppl_batch_num,
   ppl_pump_date,
   compr_trade_num,
   initiator_acct_num,
   deemed_bl_date,
   alloc_pay_date,
   alloc_base_price,
   alloc_disc_rate,
   transportation,
   netout_gross_qty,
   netout_net_qty,
   netout_qty_uom_code,
   ppl_batch_given_date,
   ppl_batch_received_date,
   ppl_origin_given_date,
   ppl_origin_received_date,
   ppl_timing_cycle_num,
   ppl_split_cycle_opt,
   alloc_short_cmnt,
   creation_type,
   netout_parcel_num,
   alloc_cmdty_code,
   bookout_pay_date,
   bookout_rec_date,
   alloc_match_ind,
   alloc_loc_code,
   alloc_begin_date,
   alloc_end_date,
   alloc_load_loc_code,
   book_net_price_ind,
   creation_date,
   multiple_cmdty_ind,
   price_precision,
   pay_for_del,
   pay_for_weight,
   max_alloc_item_num,
   voyage_code,
   release_doc_num,
   bookout_brkr_num,
   base_port_num,
   transfer_price,
   transfer_price_uom_code,
   transfer_price_curr_code,
   transfer_price_curr_code_to,
   transfer_price_currency_rate,
   shipment_key,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   alloc_num,
   alloc_type_code,
   mot_code,
   sch_init,
   alloc_status,
   cmnt_num,
   ppl_comp_num,
   ppl_comp_cont_num,
   sch_prd,
   ppl_batch_num,
   ppl_pump_date,
   compr_trade_num,
   initiator_acct_num,
   deemed_bl_date,
   alloc_pay_date,
   alloc_base_price,
   alloc_disc_rate,
   transportation,
   netout_gross_qty,
   netout_net_qty,
   netout_qty_uom_code,
   ppl_batch_given_date,
   ppl_batch_received_date,
   ppl_origin_given_date,
   ppl_origin_received_date,
   ppl_timing_cycle_num,
   ppl_split_cycle_opt,
   alloc_short_cmnt,
   creation_type,
   netout_parcel_num,
   alloc_cmdty_code,
   bookout_pay_date,
   bookout_rec_date,
   alloc_match_ind,
   alloc_loc_code,
   alloc_begin_date,
   alloc_end_date,
   alloc_load_loc_code,
   book_net_price_ind,
   creation_date,
   multiple_cmdty_ind,
   price_precision,
   pay_for_del,
   pay_for_weight,
   max_alloc_item_num,
   voyage_code,
   release_doc_num,
   bookout_brkr_num,
   base_port_num,
   transfer_price,
   transfer_price_uom_code,
   transfer_price_curr_code,
   transfer_price_curr_code_to,
   transfer_price_currency_rate,
   shipment_key,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_allocation
GO
GRANT SELECT ON  [dbo].[v_allocation_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_allocation_rev] TO [next_usr]
GO
