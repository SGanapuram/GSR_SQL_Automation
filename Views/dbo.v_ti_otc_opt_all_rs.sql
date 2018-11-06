SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_ti_otc_opt_all_rs]
(
   trade_num,
   order_num,
   item_num,
   put_call_ind,
   opt_type,
   settlement_type,
   premium,
   premium_uom_code,
   premium_curr_code,
   premium_pay_date,
   credit_term_code,
   strike_price,
   strike_price_uom_code,
   strike_price_curr_code,
   price_date_from,
   price_date_to,
   apo_special_cond_code,
   exp_date,
   exp_zone_code,
   lookback_cond_code,
   lookback_last_date,
   strike_excer_date,
   pay_term_code,
   desired_opt_eval_method,
   desired_otc_opt_code,
   trans_id,
   resp_trans_id,
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
   maintb.put_call_ind,
   maintb.opt_type,
   maintb.settlement_type,
   maintb.premium,
   maintb.premium_uom_code,
   maintb.premium_curr_code,
   maintb.premium_pay_date,
   maintb.credit_term_code,
   maintb.strike_price,
   maintb.strike_price_uom_code,
   maintb.strike_price_curr_code,
   maintb.price_date_from,
   maintb.price_date_to,
   maintb.apo_special_cond_code,
   maintb.exp_date,
   maintb.exp_zone_code,
   maintb.lookback_cond_code,
   maintb.lookback_last_date,
   maintb.strike_excer_date,
   maintb.pay_term_code,
   maintb.desired_opt_eval_method,
   maintb.desired_otc_opt_code,
   maintb.trans_id,
   null,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade_item_otc_opt maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.put_call_ind,
   audtb.opt_type,
   audtb.settlement_type,
   audtb.premium,
   audtb.premium_uom_code,
   audtb.premium_curr_code,
   audtb.premium_pay_date,
   audtb.credit_term_code,
   audtb.strike_price,
   audtb.strike_price_uom_code,
   audtb.strike_price_curr_code,
   audtb.price_date_from,
   audtb.price_date_to,
   audtb.apo_special_cond_code,
   audtb.exp_date,
   audtb.exp_zone_code,
   audtb.lookback_cond_code,
   audtb.lookback_last_date,
   audtb.strike_excer_date,
   audtb.pay_term_code,
   audtb.desired_opt_eval_method,
   audtb.desired_otc_opt_code,
   audtb.trans_id,
   audtb.resp_trans_id,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade_item_otc_opt audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ti_otc_opt_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_ti_otc_opt_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_ti_otc_opt_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_ti_otc_opt_all_rs', NULL, NULL
GO
