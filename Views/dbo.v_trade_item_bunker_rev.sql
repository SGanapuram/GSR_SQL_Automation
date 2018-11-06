SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_bunker_rev]
(
   trade_num,
   order_num,
   item_num,
   port_loc_code,
   port_agent_num,
   storage_loc_code,
   pay_term_code,
   del_term_code,
   del_agent_num,
   credit_term_code,
   mot_code,
   delivery_mot,
   eta_date,
   del_date,
   pricing_exp_date,
   exp_time_zone_code,
   curr_exch_date,
   transp_price_amt,
   transp_price_curr_code,
   transp_price_uom_code,
   handling_type_code,
   tol_qty,
   tol_qty_uom_code,
   tol_sign,
   tol_opt,
   min_qty,
   min_qty_uom_code,
   max_qty,
   max_qty_uom_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   port_loc_code,
   port_agent_num,
   storage_loc_code,
   pay_term_code,
   del_term_code,
   del_agent_num,
   credit_term_code,
   mot_code,
   delivery_mot,
   eta_date,
   del_date,
   pricing_exp_date,
   exp_time_zone_code,
   curr_exch_date,
   transp_price_amt,
   transp_price_curr_code,
   transp_price_uom_code,
   handling_type_code,
   tol_qty,
   tol_qty_uom_code,
   tol_sign,
   tol_opt,
   min_qty,
   min_qty_uom_code,
   max_qty,
   max_qty_uom_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_bunker
GO
GRANT SELECT ON  [dbo].[v_trade_item_bunker_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_bunker_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_bunker_rev', NULL, NULL
GO
