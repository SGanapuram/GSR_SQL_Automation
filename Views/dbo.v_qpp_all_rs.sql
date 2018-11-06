SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_qpp_all_rs]
(
   trade_num,
   order_num,
   item_num,
   accum_num,
   qpp_num,
   formula_num,
   formula_body_num,
   formula_comp_num,
   real_trading_prd,
   risk_trading_prd,
   nominal_start_date,
   nominal_end_date,
   quote_start_date,
   quote_end_date,
   num_of_pricing_days,
   num_of_days_priced,
   total_qty,
   priced_qty,
   qty_uom_code,
   priced_price,
   open_price,
   price_curr_code,
   price_uom_code,
   last_pricing_date,
   manual_override_ind,
   trans_id,
   resp_trans_id,
   cal_impact_start_date,
   cal_impact_end_date,
   calendar_code,
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
   maintb.accum_num,
   maintb.qpp_num,
   maintb.formula_num,
   maintb.formula_body_num,
   maintb.formula_comp_num,
   maintb.real_trading_prd,
   maintb.risk_trading_prd,
   maintb.nominal_start_date,
   maintb.nominal_end_date,
   maintb.quote_start_date,
   maintb.quote_end_date,
   maintb.num_of_pricing_days,
   maintb.num_of_days_priced,
   maintb.total_qty,
   maintb.priced_qty,
   maintb.qty_uom_code,
   maintb.priced_price,
   maintb.open_price,
   maintb.price_curr_code,
   maintb.price_uom_code,
   maintb.last_pricing_date,
   maintb.manual_override_ind,
   maintb.trans_id,
   null,
   maintb.cal_impact_start_date,
   maintb.cal_impact_end_date,
   maintb.calendar_code,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.quote_pricing_period maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.accum_num,
   audtb.qpp_num,
   audtb.formula_num,
   audtb.formula_body_num,
   audtb.formula_comp_num,
   audtb.real_trading_prd,
   audtb.risk_trading_prd,
   audtb.nominal_start_date,
   audtb.nominal_end_date,
   audtb.quote_start_date,
   audtb.quote_end_date,
   audtb.num_of_pricing_days,
   audtb.num_of_days_priced,
   audtb.total_qty,
   audtb.priced_qty,
   audtb.qty_uom_code,
   audtb.priced_price,
   audtb.open_price,
   audtb.price_curr_code,
   audtb.price_uom_code,
   audtb.last_pricing_date,
   audtb.manual_override_ind,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.cal_impact_start_date,
   audtb.cal_impact_end_date,
   audtb.calendar_code,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_quote_pricing_period audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_qpp_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_qpp_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_qpp_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_qpp_all_rs', NULL, NULL
GO
