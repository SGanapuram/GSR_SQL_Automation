SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_ti_dry_phy_all_rs]
(
   trade_num,
   order_num,
   item_num,
   min_qty,
   min_qty_uom_code,
   max_qty,
   max_qty_uom_code,
   del_date_from,
   del_date_to,
   del_date_est_ind,
   del_date_basis,
   credit_term_code,
   pay_days,
   pay_term_code,
   trade_imp_rec_ind,
   trade_exp_rec_ind,
   del_term_code,
   mot_code,
   del_loc_type,
   del_loc_code,
   transportation,
   tol_qty,
   tol_qty_uom_code,
   tol_sign,
   tol_opt,
   min_ship_qty,
   min_ship_qty_uom_code,
   partial_deadline_date,
   partial_res_inc_amt,
   sch_init,
   total_ship_num,
   parcel_num,
   taken_to_sch_pos_ind,
   proc_deal_lifting_days,
   proc_deal_delivery_type,
   proc_deal_event_name,
   proc_deal_event_spec,
   item_petroex_num,
   title_transfer_doc,
   lease_num,
   lease_ver_num,
   dest_trade_num,
   dest_order_num,
   dest_item_num,
   density_ind,
   imp_rec_reason_oid,
   prelim_price_type,
   prelim_price,
   prelim_qty_base,
   prelim_percentage,
   prelim_pay_term_code,
   prelim_due_date,
   declar_date_type,
   declar_rel_days,
   tax_qualification_code,
   tank_num,
   estimate_qty,
   b2b_sale_ind,
   facility_code,
   credit_approver_init,
   credit_approval_date,
   wet_qty,
   dry_qty,
   franchise_charge,
   heat_adj_ind,
   sublots_ind,
   umpire_rule_num,
   trans_id,
   resp_trans_id,
   int_val,
   float_val,
   str_val,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.trade_num,
   maintb.order_num,
   maintb.item_num,
   maintb.min_qty,
   maintb.min_qty_uom_code,
   maintb.max_qty,
   maintb.max_qty_uom_code,
   maintb.del_date_from,
   maintb.del_date_to,
   maintb.del_date_est_ind,
   maintb.del_date_basis,
   maintb.credit_term_code,
   maintb.pay_days,
   maintb.pay_term_code,
   maintb.trade_imp_rec_ind,
   maintb.trade_exp_rec_ind,
   maintb.del_term_code,
   maintb.mot_code,
   maintb.del_loc_type,
   maintb.del_loc_code,
   maintb.transportation,
   maintb.tol_qty,
   maintb.tol_qty_uom_code,
   maintb.tol_sign,
   maintb.tol_opt,
   maintb.min_ship_qty,
   maintb.min_ship_qty_uom_code,
   maintb.partial_deadline_date,
   maintb.partial_res_inc_amt,
   maintb.sch_init,
   maintb.total_ship_num,
   maintb.parcel_num,
   maintb.taken_to_sch_pos_ind,
   maintb.proc_deal_lifting_days,
   maintb.proc_deal_delivery_type,
   maintb.proc_deal_event_name,
   maintb.proc_deal_event_spec,
   maintb.item_petroex_num,
   maintb.title_transfer_doc,
   maintb.lease_num,
   maintb.lease_ver_num,
   maintb.dest_trade_num,
   maintb.dest_order_num,
   maintb.dest_item_num,
   maintb.density_ind,
   maintb.imp_rec_reason_oid,
   maintb.prelim_price_type,
   maintb.prelim_price,
   maintb.prelim_qty_base,
   maintb.prelim_percentage,
   maintb.prelim_pay_term_code,
   maintb.prelim_due_date,
   maintb.declar_date_type,
   maintb.declar_rel_days,
   maintb.tax_qualification_code,
   maintb.tank_num,
   maintb.estimate_qty,
   maintb.b2b_sale_ind,
   maintb.facility_code,
   maintb.credit_approver_init,
   maintb.credit_approval_date,
   maintb.wet_qty,
   maintb.dry_qty,
   maintb.franchise_charge,
   maintb.heat_adj_ind,
   maintb.sublots_ind,
   maintb.umpire_rule_num,
   maintb.trans_id,
   null,
   maintb.int_val,
   maintb.float_val,
   maintb.str_val,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade_item_dry_phy maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.min_qty,
   audtb.min_qty_uom_code,
   audtb.max_qty,
   audtb.max_qty_uom_code,
   audtb.del_date_from,
   audtb.del_date_to,
   audtb.del_date_est_ind,
   audtb.del_date_basis,
   audtb.credit_term_code,
   audtb.pay_days,
   audtb.pay_term_code,
   audtb.trade_imp_rec_ind,
   audtb.trade_exp_rec_ind,
   audtb.del_term_code,
   audtb.mot_code,
   audtb.del_loc_type,
   audtb.del_loc_code,
   audtb.transportation,
   audtb.tol_qty,
   audtb.tol_qty_uom_code,
   audtb.tol_sign,
   audtb.tol_opt,
   audtb.min_ship_qty,
   audtb.min_ship_qty_uom_code,
   audtb.partial_deadline_date,
   audtb.partial_res_inc_amt,
   audtb.sch_init,
   audtb.total_ship_num,
   audtb.parcel_num,
   audtb.taken_to_sch_pos_ind,
   audtb.proc_deal_lifting_days,
   audtb.proc_deal_delivery_type,
   audtb.proc_deal_event_name,
   audtb.proc_deal_event_spec,
   audtb.item_petroex_num,
   audtb.title_transfer_doc,
   audtb.lease_num,
   audtb.lease_ver_num,
   audtb.dest_trade_num,
   audtb.dest_order_num,
   audtb.dest_item_num,
   audtb.density_ind,
   audtb.imp_rec_reason_oid,
   audtb.prelim_price_type,
   audtb.prelim_price,
   audtb.prelim_qty_base,
   audtb.prelim_percentage,
   audtb.prelim_pay_term_code,
   audtb.prelim_due_date,
   audtb.declar_date_type,
   audtb.declar_rel_days,
   audtb.tax_qualification_code,
   audtb.tank_num,
   audtb.estimate_qty,
   audtb.b2b_sale_ind,
   audtb.facility_code,
   audtb.credit_approver_init,
   audtb.credit_approval_date,
   audtb.wet_qty,
   audtb.dry_qty,
   audtb.franchise_charge,
   audtb.heat_adj_ind,
   audtb.sublots_ind,
   audtb.umpire_rule_num,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.int_val,
   audtb.float_val,
   audtb.str_val,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade_item_dry_phy audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ti_dry_phy_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_ti_dry_phy_all_rs] TO [next_usr]
GO
