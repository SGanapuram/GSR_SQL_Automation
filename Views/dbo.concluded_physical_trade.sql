SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[concluded_physical_trade]
(
   trade_num,
   order_num,
   item_num,
   order_type_code,
   bal_ind,
   trader_init,
   acct_num,
   acct_cont_num,
   acct_short_name,
   cr_anly_init,
   p_s_ind,
   booking_comp_num,
   cmdty_code,
   risk_mkt_code,
   title_mkt_code,
   trading_prd,
   open_qty,
   contr_qty,
   contr_qty_uom_code,
   formula_ind,
   avg_price,
   price_curr_code,
   price_uom_code,
   cmnt_num,
   min_qty,
   min_qty_uom_code,
   max_qty,
   max_qty_uom_code,
   total_sch_qty,
   sch_qty_uom_code,
   del_date_from,
   del_date_to,
   del_date_est_ind,
   pipeline_cycle_num,
   timing_cycle_year,
   credit_term_code,
   pay_days,
   pay_term_code,
   trade_imp_rec_ind,
   del_term_code,
   mot_code,
   del_loc_code,
   vessel_name,
   tol_qty,
   tol_qty_uom_code,
   tol_sign,
   tol_opt,
   brkr_num,
   brkr_cont_num,
   brkr_comm_amt,
   brkr_comm_curr_code,
   brkr_comm_uom_code,
   brkr_ref_num,
   min_ship_qty,
   min_ship_qty_uom_code,
   partial_deadline_date,
   partial_res_inc_amt,
   sch_init,
   total_ship_num,
   parcel_num,
   taken_to_sch_pos_ind,
   trans_id
)
as 
select
   t.trade_num,
   o.order_num,
   ti.item_num,
   o.order_type_code,
   o.bal_ind,
   t.trader_init,
   t.acct_num,
   t.acct_cont_num,
   t.acct_short_name,
   t.cr_anly_init,
   ti.p_s_ind,
   ti.booking_comp_num,
   ti.cmdty_code,
   ti.risk_mkt_code,
   ti.title_mkt_code,
   ti.trading_prd,
   convert(float, ti.contr_qty - isnull(ti.total_sch_qty, 0)),
   ti.contr_qty,
   ti.contr_qty_uom_code,
   ti.formula_ind,
   ti.avg_price,
   ti.price_curr_code,
   ti.price_uom_code,
   ti.cmnt_num,
   tiwp.min_qty,
   tiwp.min_qty_uom_code,
   tiwp.max_qty,
   tiwp.max_qty_uom_code,
   convert(float, isnull(ti.total_sch_qty, 0)),
   ti.sch_qty_uom_code,
   tiwp.del_date_from,
   tiwp.del_date_to,
   tiwp.del_date_est_ind,
   tiwp.pipeline_cycle_num,
   tiwp.timing_cycle_year,
   tiwp.credit_term_code,
   tiwp.pay_days,
   tiwp.pay_term_code,
   tiwp.trade_imp_rec_ind,
   tiwp.del_term_code,
   tiwp.mot_code,
   tiwp.del_loc_code,
   tiwp.transportation,
   tiwp.tol_qty,
   tiwp.tol_qty_uom_code,
   tiwp.tol_sign,
   tiwp.tol_opt,
   ti.brkr_num,
   ti.brkr_cont_num,
   ti.brkr_comm_amt,
   ti.brkr_comm_curr_code,
   ti.brkr_comm_uom_code,
   ti.brkr_ref_num,
   tiwp.min_ship_qty,
   tiwp.min_ship_qty_uom_code,
   tiwp.partial_deadline_date,
   tiwp.partial_res_inc_amt,
   tiwp.sch_init,
   tiwp.total_ship_num,
   tiwp.parcel_num,
   tiwp.taken_to_sch_pos_ind,
   tiwp.trans_id
from dbo.trade t,
     dbo.trade_order o,
     dbo.trade_item ti,
     dbo.trade_item_wet_phy tiwp
where t.conclusion_type = 'C' and   
      t.inhouse_ind = 'N' and   
      t.trade_num = o.trade_num and
      o.trade_num = ti.trade_num and   
      o.order_num = ti.order_num and   
      ti.item_type = 'W' and   
      ti.trade_num = tiwp.trade_num and   
      ti.order_num = tiwp.order_num and   
      ti.item_num  = tiwp.item_num and   
      ti.contr_qty - isnull(ti.total_sch_qty, 0) > 0
GO
GRANT SELECT ON  [dbo].[concluded_physical_trade] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[concluded_physical_trade] TO [next_usr]
GO
