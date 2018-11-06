SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[WPTI_cost_view]
(
   trade_num,
   trader_init,
   trade_status_code,
   conclusion_type,
   inhouse_ind,
   acct_num,
   acct_cont_num,
   acct_short_name,
   acct_ref_num,
   port_num,
   concluded_date,
   contr_approv_type,
   contr_date,
   cr_anly_init,
   cp_gov_contr_ind,
   contr_exch_method,
   contr_cnfrm_method,
   contr_tlx_hold_ind,
   creation_date,
   creator_init,
   trade_mod_date,
   trade_mod_init,
   invoice_cap_type,
   internal_agreement_ind,
   credit_status,
   credit_res_exp_date,
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
   pipeline_cycle_num,
   timing_cycle_year,
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
   cost_adj_qty_1,
   cost_adj_qty_2,
   pp_qty_adj_rule_num,
   loc_name,
   country_code,
   state_code,
   dflt_mot_code
)
as
select
   trd.trade_num,
   trd.trader_init,
   trd.trade_status_code,
   trd.conclusion_type,
   trd.inhouse_ind,
   trd.acct_num,
   trd.acct_cont_num,
   trd.acct_short_name,
   trd.acct_ref_num,
   trd.port_num,
   trd.concluded_date,
   trd.contr_approv_type,
   trd.contr_date,
   trd.cr_anly_init,
   trd.cp_gov_contr_ind,
   trd.contr_exch_method,
   trd.contr_cnfrm_method,
   trd.contr_tlx_hold_ind,
   trd.creation_date,
   trd.creator_init,
   trd.trade_mod_date,
   trd.trade_mod_init,
   trd.invoice_cap_type,
   trd.internal_agreement_ind,
   trd.credit_status,
   trd.credit_res_exp_date,
   tiwp.order_num,
   tiwp.item_num,
   tiwp.min_qty,
   tiwp.min_qty_uom_code,
   tiwp.max_qty,
   tiwp.max_qty_uom_code,
   tiwp.del_date_from,
   tiwp.del_date_to,
   tiwp.del_date_est_ind,
   tiwp.del_date_basis,
   tiwp.pipeline_cycle_num,
   tiwp.timing_cycle_year,
   tiwp.credit_term_code,
   tiwp.pay_days,
   tiwp.pay_term_code,
   tiwp.trade_imp_rec_ind,
   tiwp.trade_exp_rec_ind,
   tiwp.del_term_code,
   tiwp.mot_code,
   tiwp.del_loc_type,
   tiwp.del_loc_code,
   tiwp.transportation,
   tiwp.tol_qty,
   tiwp.tol_qty_uom_code,
   tiwp.tol_sign,
   tiwp.tol_opt,
   tiwp.min_ship_qty,
   tiwp.min_ship_qty_uom_code,
   tiwp.partial_deadline_date,
   tiwp.partial_res_inc_amt,
   tiwp.sch_init,
   tiwp.total_ship_num,
   tiwp.parcel_num,
   tiwp.taken_to_sch_pos_ind,
   tiwp.proc_deal_lifting_days,
   tiwp.proc_deal_delivery_type,
   tiwp.proc_deal_event_name,
   tiwp.proc_deal_event_spec,
   tiwp.item_petroex_num,
   tiwp.title_transfer_doc,
   tiwp.lease_num,
   tiwp.lease_ver_num,
   tiwp.dest_trade_num,
   tiwp.dest_order_num,
   tiwp.dest_item_num,
   tiwp.density_ind,
   tiwp.cost_adj_qty_1,
   tiwp.cost_adj_qty_2,
   tiwp.pp_qty_adj_rule_num,
   loc.loc_name,
   locext.country_code,
   locext.state_code,
   locext.dflt_mot_code
from dbo.trade trd,
     dbo.trade_order trdord,
     dbo.trade_item_wet_phy tiwp,
     dbo.location loc,
     dbo.location_ext_info locext
where trd.conclusion_type = 'C' and
      trd.inhouse_ind = 'N' and
      trd.trade_num = trdord.trade_num and
      trdord.strip_summary_ind = 'N' and
      trdord.trade_num = tiwp.trade_num and
      trdord.order_num = tiwp.order_num and
      loc.loc_code = tiwp.del_loc_code and
      locext.loc_code = tiwp.del_loc_code
GO
GRANT SELECT ON  [dbo].[WPTI_cost_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[WPTI_cost_view] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'WPTI_cost_view', NULL, NULL
GO
