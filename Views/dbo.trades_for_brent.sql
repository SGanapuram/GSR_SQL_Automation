SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[trades_for_brent]
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
	 total_price,
	 priced_qty_uom_code, 			
	 avg_price,
	 price_curr_code,				
	 price_uom_code,					
	 cmnt_num,						
	 total_sch_qty,
	 total_sch_qty_uom_code,			
	 del_date_from,
	 del_date_to,
	 brkr_num,						
	 brkr_cont_num,					
	 brkr_comm_amt,
	 brkr_comm_curr_code,			
	 brkr_comm_uom_code,
	 brkr_ref_num,
   parcel_num
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
	 total_sch_qty = isnull(ti.total_sch_qty, 0),
	 ti.sch_qty_uom_code,
   tw.del_date_from,
   tw.del_date_to,
	 ti.brkr_num,
	 ti.brkr_cont_num,
	 ti.brkr_comm_amt,
	 ti.brkr_comm_curr_code,
	 ti.brkr_comm_uom_code,
	 ti.brkr_ref_num,
	 tw.parcel_num
from dbo.trade t, 
     dbo.trade_order o, 
     dbo.trade_item ti, 
     dbo.trade_item_wet_phy tw
where t.conclusion_type = 'C' and
      t.inhouse_ind = 'N' and
      t.trade_num = o.trade_num and
      o.trade_num = ti.trade_num and
      o.order_num = ti.order_num and
      ti.item_type in ('W', 'P') and
      ti.trade_num = tw.trade_num and
      ti.order_num = tw.order_num and
      ti.item_num  = tw.item_num and
      isnull(ti.open_qty, 0) > 0
GO
GRANT SELECT ON  [dbo].[trades_for_brent] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[trades_for_brent] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'trades_for_brent', NULL, NULL
GO
