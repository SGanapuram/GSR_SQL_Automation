SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[trades_for_sch]
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
	 open_qty_uom_code,				
	 contr_qty,
	 contr_qty_uom_code,				
	 formula_ind,
	 total_priced_qty,
	 priced_qty_uom_code, 			
	 avg_price,
	 price_curr_code,				
	 price_uom_code,					
	 cmnt_num,						
	 min_qty,
	 min_qty_uom_code,				
	 max_qty,
	 max_qty_uom_code,				
	 total_sch_qty,
	 total_sch_qty_uom_code,			
	 del_date_from,
	 del_date_to,
	 del_date_est_ind,
	 timing_cycle_num,
	 split_cycle_opt,
	 credit_term_code,				
	 pay_days,
	 pay_term_code,					
	 trade_imp_rec_ind,
	 del_term_code,					
	 mot_code,						
	 del_loc_code,					
	 transportation,
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
   load_loc_code,
   creation_date,
   real_port_num,
   acct_ref_num,
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
   open_qty = isnull(ti.open_qty, 0),
   ti.open_qty_uom_code,
	 ti.contr_qty,
	 ti.contr_qty_uom_code,
	 ti.formula_ind,
	 ti.total_priced_qty,
	 ti.priced_qty_uom_code,
	 ti.avg_price,
	 ti.price_curr_code,
	 ti.price_uom_code,
	 ti.cmnt_num,
	 tc.min_qty,
	 tc.min_qty_uom_code,
	 tc.max_qty,
	 tc.max_qty_uom_code,
	 total_sch_qty = isnull(ti.total_sch_qty, 0),
	 ti.sch_qty_uom_code,
	 tc.del_date_from,
	 tc.del_date_to,
	 tc.del_date_est_ind,
	 tc.timing_cycle_num,
	 tc.split_cycle_opt,
	 tc.credit_term_code,
	 tc.pay_days,
	 tc.pay_term_code,
	 tc.trade_imp_rec_ind,
	 tc.del_term_code,
	 tc.mot_code,
	 tc.del_loc_code,
	 tc.transportation,
	 tc.tol_qty,
	 tc.tol_qty_uom_code,
	 tc.tol_sign,
	 tc.tol_opt,
	 ti.brkr_num,
	 ti.brkr_cont_num,
	 ti.brkr_comm_amt,
	 ti.brkr_comm_curr_code,
	 ti.brkr_comm_uom_code,
	 ti.brkr_ref_num,
	 tc.min_ship_qty,
	 tc.min_ship_qty_uom_code,
	 tc.partial_deadline_date,
	 tc.partial_res_inc_amt,
	 tc.sch_init,
	 tc.total_ship_num,
	 tc.parcel_num,
	 tc.taken_to_sch_pos_ind,
	 tc.load_loc_code,
	 t.creation_date,
	 tc.real_port_num,
	 tc.acct_ref_num,
   tc.trans_id
from dbo.trade t,
     dbo.trade_order o,
     dbo.trade_item ti,
     dbo.trade_item_composite tc
where t.conclusion_type = 'C' and
      t.inhouse_ind = 'N' and
      t.trade_num = o.trade_num and
      o.trade_num = ti.trade_num and
      o.order_num = ti.order_num and
      ti.item_type in ('W', 'P') and
      ti.trade_num = tc.trade_num and
      ti.order_num = tc.order_num and
      ti.item_num  = tc.item_num and
      isnull(ti.open_qty, 0) > 0
GO
GRANT SELECT ON  [dbo].[trades_for_sch] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[trades_for_sch] TO [next_usr]
GO
