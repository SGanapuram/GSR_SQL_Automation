SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_ti_conc_all_rs]
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
    tic.trade_num,
    tic.order_num,
    tic.item_num,
    tic.min_qty,
    tic.min_qty_uom_code,
    tic.max_qty,
    tic.max_qty_uom_code,
    tic.del_date_from,
    tic.del_date_to,
    tic.del_date_est_ind,
    tic.del_date_basis,
    tic.credit_term_code,
    tic.pay_days,
    tic.pay_term_code,
    tic.trade_imp_rec_ind,
    tic.trade_exp_rec_ind,
    tic.del_term_code,
    tic.mot_code,
    tic.del_loc_type,
    tic.del_loc_code,
    tic.transportation,
    tic.tol_qty,
    tic.tol_qty_uom_code,
    tic.tol_sign,
    tic.tol_opt,
    tic.min_ship_qty,
    tic.min_ship_qty_uom_code,
    tic.partial_deadline_date,
    tic.partial_res_inc_amt,
    tic.sch_init,
    tic.total_ship_num,
    tic.parcel_num,
    tic.taken_to_sch_pos_ind,
    tic.proc_deal_lifting_days,
    tic.proc_deal_delivery_type,
    tic.proc_deal_event_name,
    tic.proc_deal_event_spec,
    tic.item_petroex_num,
    tic.title_transfer_doc,
    tic.lease_num,
    tic.lease_ver_num,
    tic.dest_trade_num,
    tic.dest_order_num,
    tic.dest_item_num,
    tic.density_ind,
    tic.imp_rec_reason_oid,
    tic.prelim_price_type,
    tic.prelim_price,
    tic.prelim_qty_base,
    tic.prelim_percentage,
    tic.prelim_pay_term_code,
    tic.prelim_due_date,
    tic.declar_date_type,
    tic.declar_rel_days,
    tic.tax_qualification_code,
    tic.tank_num,
    tic.estimate_qty,
    tic.b2b_sale_ind,
    tic.facility_code,
    tic.credit_approver_init,
    tic.credit_approval_date,
    tic.wet_qty,
    tic.dry_qty,
    tic.franchise_charge,
    tic.heat_adj_ind,
    tic.sublots_ind,
    tic.umpire_rule_num,
    null,
    tic.trans_id,
    it.type,
    it.user_init,
    it.tran_date,
    it.app_name,
    it.workstation_id,
    it.sequence
from dbo.trade_item_conc tic
    left outer join dbo.icts_transaction it
        on tic.trans_id = it.trans_id
union
select
    tic.trade_num,
    tic.order_num,
    tic.item_num,
    tic.min_qty,
    tic.min_qty_uom_code,
    tic.max_qty,
    tic.max_qty_uom_code,
    tic.del_date_from,
    tic.del_date_to,
    tic.del_date_est_ind,
    tic.del_date_basis,
    tic.credit_term_code,
    tic.pay_days,
    tic.pay_term_code,
    tic.trade_imp_rec_ind,
    tic.trade_exp_rec_ind,
    tic.del_term_code,
    tic.mot_code,
    tic.del_loc_type,
    tic.del_loc_code,
    tic.transportation,
    tic.tol_qty,
    tic.tol_qty_uom_code,
    tic.tol_sign,
    tic.tol_opt,
    tic.min_ship_qty,
    tic.min_ship_qty_uom_code,
    tic.partial_deadline_date,
    tic.partial_res_inc_amt,
    tic.sch_init,
    tic.total_ship_num,
    tic.parcel_num,
    tic.taken_to_sch_pos_ind,
    tic.proc_deal_lifting_days,
    tic.proc_deal_delivery_type,
    tic.proc_deal_event_name,
    tic.proc_deal_event_spec,
    tic.item_petroex_num,
    tic.title_transfer_doc,
    tic.lease_num,
    tic.lease_ver_num,
    tic.dest_trade_num,
    tic.dest_order_num,
    tic.dest_item_num,
    tic.density_ind,
    tic.imp_rec_reason_oid,
    tic.prelim_price_type,
    tic.prelim_price,
    tic.prelim_qty_base,
    tic.prelim_percentage,
    tic.prelim_pay_term_code,
    tic.prelim_due_date,
    tic.declar_date_type,
    tic.declar_rel_days,
    tic.tax_qualification_code,
    tic.tank_num,
    tic.estimate_qty,
    tic.b2b_sale_ind,
    tic.facility_code,
    tic.credit_approver_init,
    tic.credit_approval_date,
    tic.wet_qty,
    tic.dry_qty,
    tic.franchise_charge,
    tic.heat_adj_ind,
    tic.sublots_ind,
    tic.umpire_rule_num,
    tic.resp_trans_id,
    tic.trans_id,
    it.type,
    it.user_init,
    it.tran_date,
    it.app_name,
    it.workstation_id,
    it.sequence
from dbo.aud_trade_item_conc tic
    left outer join dbo.icts_transaction it
        on tic.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ti_conc_all_rs] TO [next_usr]
GO
