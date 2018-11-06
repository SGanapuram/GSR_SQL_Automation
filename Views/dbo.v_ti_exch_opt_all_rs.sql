SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_ti_exch_opt_all_rs]
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
   strike_price,
   strike_price_uom_code,
   strike_price_curr_code,
   exp_date,
   exp_zone_code,
   total_fill_qty,
   fill_qty_uom_code,
   avg_fill_price,
   strike_excer_date,
   clr_brkr_num,
   clr_brkr_cont_num,
   clr_brkr_comm_amt,
   clr_brkr_comm_curr_code,
   clr_brkr_comm_uom_code,
   clr_brkr_ref_num,
   surrender_qty,
   trans_id,
   resp_trans_id,
   use_in_fifo_ind,
   exec_type_code,
   price_source_code,
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
   maintb.strike_price,
   maintb.strike_price_uom_code,
   maintb.strike_price_curr_code,
   maintb.exp_date,
   maintb.exp_zone_code,
   maintb.total_fill_qty,
   maintb.fill_qty_uom_code,
   maintb.avg_fill_price,
   maintb.strike_excer_date,
   maintb.clr_brkr_num,
   maintb.clr_brkr_cont_num,
   maintb.clr_brkr_comm_amt,
   maintb.clr_brkr_comm_curr_code,
   maintb.clr_brkr_comm_uom_code,
   maintb.clr_brkr_ref_num,
   maintb.surrender_qty,
   maintb.trans_id,
   null,
   maintb.use_in_fifo_ind,
   maintb.exec_type_code,
   maintb.price_source_code,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade_item_exch_opt maintb
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
   audtb.strike_price,
   audtb.strike_price_uom_code,
   audtb.strike_price_curr_code,
   audtb.exp_date,
   audtb.exp_zone_code,
   audtb.total_fill_qty,
   audtb.fill_qty_uom_code,
   audtb.avg_fill_price,
   audtb.strike_excer_date,
   audtb.clr_brkr_num,
   audtb.clr_brkr_cont_num,
   audtb.clr_brkr_comm_amt,
   audtb.clr_brkr_comm_curr_code,
   audtb.clr_brkr_comm_uom_code,
   audtb.clr_brkr_ref_num,
   audtb.surrender_qty,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.use_in_fifo_ind,
   audtb.exec_type_code,
   audtb.price_source_code,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade_item_exch_opt audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_ti_exch_opt_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_ti_exch_opt_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_ti_exch_opt_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_ti_exch_opt_all_rs', NULL, NULL
GO