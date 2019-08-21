SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAllocationRevPK]
(
   @alloc_num          int,
   @asof_trans_id      bigint
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.allocation
where alloc_num = @alloc_num
 
if @trans_id <= @asof_trans_id
begin
   select
      alloc_base_price,
      alloc_begin_date,
      alloc_cmdty_code,
      alloc_disc_rate,
      alloc_end_date,
      alloc_load_loc_code,
      alloc_loc_code,
      alloc_match_ind,
      alloc_num,
      alloc_pay_date,
      alloc_short_cmnt,
      alloc_status,
      alloc_type_code,
      asof_trans_id = @asof_trans_id,
      base_port_num,
      book_net_price_ind,
      bookout_brkr_num,
      bookout_pay_date,
      bookout_rec_date,
      cmnt_num,
      compr_trade_num,
      creation_date,
      creation_type,
      deemed_bl_date,
      initiator_acct_num,
      max_alloc_item_num,
      mot_code,
      multiple_cmdty_ind,
      netout_gross_qty,
      netout_net_qty,
      netout_parcel_num,
      netout_qty_uom_code,
      pay_for_del,
      pay_for_weight,
      ppl_batch_given_date,
      ppl_batch_num,
      ppl_batch_received_date,
      ppl_comp_cont_num,
      ppl_comp_num,
      ppl_origin_given_date,
      ppl_origin_received_date,
      ppl_pump_date,
      ppl_split_cycle_opt,
      ppl_timing_cycle_num,
      price_precision,
      release_doc_num,
      resp_trans_id = null,
      sch_init,
      sch_prd,
	  shipment_key,
      trans_id,
      transfer_price,
      transfer_price_curr_code,
      transfer_price_curr_code_to,
      transfer_price_currency_rate,
      transfer_price_uom_code,
      transportation,
      voyage_code
   from dbo.allocation
   where alloc_num = @alloc_num
end
else
begin
   select top 1
      alloc_base_price,
      alloc_begin_date,
      alloc_cmdty_code,
      alloc_disc_rate,
      alloc_end_date,
      alloc_load_loc_code,
      alloc_loc_code,
      alloc_match_ind,
      alloc_num,
      alloc_pay_date,
      alloc_short_cmnt,
      alloc_status,
      alloc_type_code,
      asof_trans_id = @asof_trans_id,
      base_port_num,
      book_net_price_ind,
      bookout_brkr_num,
      bookout_pay_date,
      bookout_rec_date,
      cmnt_num,
      compr_trade_num,
      creation_date,
      creation_type,
      deemed_bl_date,
      initiator_acct_num,
      max_alloc_item_num,
      mot_code,
      multiple_cmdty_ind,
      netout_gross_qty,
      netout_net_qty,
      netout_parcel_num,
      netout_qty_uom_code,
      pay_for_del,
      pay_for_weight,
      ppl_batch_given_date,
      ppl_batch_num,
      ppl_batch_received_date,
      ppl_comp_cont_num,
      ppl_comp_num,
      ppl_origin_given_date,
      ppl_origin_received_date,
      ppl_pump_date,
      ppl_split_cycle_opt,
      ppl_timing_cycle_num,
      price_precision,
      release_doc_num,
      resp_trans_id,
      sch_init,
      sch_prd,
	  shipment_key,
      trans_id,
      transfer_price,
      transfer_price_curr_code,
      transfer_price_curr_code_to,
      transfer_price_currency_rate,
      transfer_price_uom_code,
      transportation,
      voyage_code
   from dbo.aud_allocation
   where alloc_num = @alloc_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAllocationRevPK] TO [next_usr]
GO
