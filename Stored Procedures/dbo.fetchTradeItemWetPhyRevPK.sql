SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemWetPhyRevPK]
(
   @asof_trans_id      bigint,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trade_item_wet_phy
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      b2b_sale_ind,
      cost_adj_qty_1,
      cost_adj_qty_2,
      credit_approval_date,
      credit_approver_init,
      credit_term_code,
      declar_date_type,
      declar_rel_days,
      del_date_basis,
      del_date_est_ind,
      del_date_from,
      del_date_to,
      del_loc_code,
      del_loc_type,
      del_term_code,
      density_ind,
      dest_item_num,
      dest_order_num,
      dest_trade_num,
      estimate_qty,
      facility_code,
      float_val,
      heat_adj_ind,
      imp_rec_reason_oid,
      int_val,
      item_num,
      item_petroex_num,
      lease_num,
      lease_ver_num,
      max_qty,
      max_qty_uom_code,
      min_qty,
      min_qty_uom_code,
      min_ship_qty,
      min_ship_qty_uom_code,
      mot_code,
      order_num,
      parcel_num,
      partial_deadline_date,
      partial_res_inc_amt,
      pay_days,
      pay_term_code,
      pipeline_cycle_num,
      pp_qty_adj_rule_num,
      prelim_due_date,
      prelim_pay_term_code,
      prelim_percentage,
      prelim_price,
      prelim_price_type,
      prelim_qty_base,
      proc_deal_delivery_type,
      proc_deal_event_name,
      proc_deal_event_spec,
      proc_deal_lifting_days,
      resp_trans_id = null,
      sch_init,
      str_val,
      taken_to_sch_pos_ind,
      tank_num,
      tax_qualification_code,
      timing_cycle_year,
      title_transfer_doc,
      tol_opt,
      tol_qty,
      tol_qty_uom_code,
      tol_sign,
      total_ship_num,
      trade_exp_rec_ind,
      trade_imp_rec_ind,
      trade_num,
      trans_id,
      transportation
   from dbo.trade_item_wet_phy
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      b2b_sale_ind,
      cost_adj_qty_1,
      cost_adj_qty_2,
      credit_approval_date,
      credit_approver_init,
      credit_term_code,
      declar_date_type,
      declar_rel_days,
      del_date_basis,
      del_date_est_ind,
      del_date_from,
      del_date_to,
      del_loc_code,
      del_loc_type,
      del_term_code,
      density_ind,
      dest_item_num,
      dest_order_num,
      dest_trade_num,
      estimate_qty,
      facility_code,
      float_val,
      heat_adj_ind,
      imp_rec_reason_oid,
      int_val,
      item_num,
      item_petroex_num,
      lease_num,
      lease_ver_num,
      max_qty,
      max_qty_uom_code,
      min_qty,
      min_qty_uom_code,
      min_ship_qty,
      min_ship_qty_uom_code,
      mot_code,
      order_num,
      parcel_num,
      partial_deadline_date,
      partial_res_inc_amt,
      pay_days,
      pay_term_code,
      pipeline_cycle_num,
      pp_qty_adj_rule_num,
      prelim_due_date,
      prelim_pay_term_code,
      prelim_percentage,
      prelim_price,
      prelim_price_type,
      prelim_qty_base,
      proc_deal_delivery_type,
      proc_deal_event_name,
      proc_deal_event_spec,
      proc_deal_lifting_days,
      resp_trans_id,
      sch_init,
      str_val,
      taken_to_sch_pos_ind,
      tank_num,
      tax_qualification_code,
      timing_cycle_year,
      title_transfer_doc,
      tol_opt,
      tol_qty,
      tol_qty_uom_code,
      tol_sign,
      total_ship_num,
      trade_exp_rec_ind,
      trade_imp_rec_ind,
      trade_num,
      trans_id,
      transportation
   from dbo.aud_trade_item_wet_phy
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemWetPhyRevPK] TO [next_usr]
GO
