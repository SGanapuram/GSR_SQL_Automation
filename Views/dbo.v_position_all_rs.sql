SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_position_all_rs]
(
   pos_num,
   real_port_num,
   pos_type,
   is_equiv_ind,
   what_if_ind,
   commkt_key,
   trading_prd,
   cmdty_code,
   mkt_code,
   formula_num,
   formula_name,
   option_type,
   settlement_type,
   strike_price,
   strike_price_curr_code,
   strike_price_uom_code,
   put_call_ind,
   opt_exp_date,
   opt_start_date,
   opt_periodicity,
   opt_price_source_code,
   acct_short_name,
   desired_opt_eval_method,
   desired_otc_opt_code,
   is_hedge_ind,
   long_qty,
   short_qty,
   discount_qty,
   priced_qty,
   qty_uom_code,
   avg_purch_price,
   avg_sale_price,
   price_curr_code,
   price_uom_code,
   sec_long_qty,
   sec_short_qty,
   sec_discount_qty,
   sec_priced_qty,
   sec_pos_uom_code,
   trans_id,
   resp_trans_id,
   pos_status,
   last_mtm_price,
   rolled_qty,
   sec_rolled_qty,
   is_cleared_ind,
   formula_body_num,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.pos_num,
   maintb.real_port_num,
   maintb.pos_type,
   maintb.is_equiv_ind,
   maintb.what_if_ind,
   maintb.commkt_key,
   maintb.trading_prd,
   maintb.cmdty_code,
   maintb.mkt_code,
   maintb.formula_num,
   maintb.formula_name,
   maintb.option_type,
   maintb.settlement_type,
   maintb.strike_price,
   maintb.strike_price_curr_code,
   maintb.strike_price_uom_code,
   maintb.put_call_ind,
   maintb.opt_exp_date,
   maintb.opt_start_date,
   maintb.opt_periodicity,
   maintb.opt_price_source_code,
   maintb.acct_short_name,
   maintb.desired_opt_eval_method,
   maintb.desired_otc_opt_code,
   maintb.is_hedge_ind,
   maintb.long_qty,
   maintb.short_qty,
   maintb.discount_qty,
   maintb.priced_qty,
   maintb.qty_uom_code,
   maintb.avg_purch_price,
   maintb.avg_sale_price,
   maintb.price_curr_code,
   maintb.price_uom_code,
   maintb.sec_long_qty,
   maintb.sec_short_qty,
   maintb.sec_discount_qty,
   maintb.sec_priced_qty,
   maintb.sec_pos_uom_code,
   maintb.trans_id,
   null,
   maintb.pos_status,
   maintb.last_mtm_price,
   maintb.rolled_qty,
   maintb.sec_rolled_qty,
   maintb.is_cleared_ind,
   maintb.formula_body_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.position maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.pos_num,
   audtb.real_port_num,
   audtb.pos_type,
   audtb.is_equiv_ind,
   audtb.what_if_ind,
   audtb.commkt_key,
   audtb.trading_prd,
   audtb.cmdty_code,
   audtb.mkt_code,
   audtb.formula_num,
   audtb.formula_name,
   audtb.option_type,
   audtb.settlement_type,
   audtb.strike_price,
   audtb.strike_price_curr_code,
   audtb.strike_price_uom_code,
   audtb.put_call_ind,
   audtb.opt_exp_date,
   audtb.opt_start_date,
   audtb.opt_periodicity,
   audtb.opt_price_source_code,
   audtb.acct_short_name,
   audtb.desired_opt_eval_method,
   audtb.desired_otc_opt_code,
   audtb.is_hedge_ind,
   audtb.long_qty,
   audtb.short_qty,
   audtb.discount_qty,
   audtb.priced_qty,
   audtb.qty_uom_code,
   audtb.avg_purch_price,
   audtb.avg_sale_price,
   audtb.price_curr_code,
   audtb.price_uom_code,
   audtb.sec_long_qty,
   audtb.sec_short_qty,
   audtb.sec_discount_qty,
   audtb.sec_priced_qty,
   audtb.sec_pos_uom_code,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.pos_status,
   audtb.last_mtm_price,
   audtb.rolled_qty,
   audtb.sec_rolled_qty,
   audtb.is_cleared_ind,
   audtb.formula_body_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_position audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_position_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_position_all_rs] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_position_all_rs', NULL, NULL
GO
