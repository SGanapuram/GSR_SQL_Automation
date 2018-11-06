SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_tid_all_rs]
(
   dist_num,
   trade_num,
   order_num,
   item_num,
   accum_num,
   qpp_num,
   pos_num,
   real_port_num,
   dist_type,
   real_synth_ind,
   is_equiv_ind,
   what_if_ind,
   bus_date,
   p_s_ind,
   dist_qty,
   alloc_qty,
   discount_qty,
   priced_qty,
   qty_uom_code,
   qty_uom_code_conv_to,
   qty_uom_conv_rate,
   price_curr_code_conv_to,
   price_curr_conv_rate,
   price_uom_code_conv_to,
   price_uom_conv_rate,
   spread_pos_group_num,
   delivered_qty,
   open_pl,
   pl_asof_date,
   closed_pl,
   addl_cost_sum,
   sec_conversion_factor,
   sec_qty_uom_code,
   commkt_key,
   trading_prd,
   trans_id,
   resp_trans_id,
   estimate_qty,
   formula_num,
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
   maintb.dist_num,
   maintb.trade_num,
   maintb.order_num,
   maintb.item_num,
   maintb.accum_num,
   maintb.qpp_num,
   maintb.pos_num,
   maintb.real_port_num,
   maintb.dist_type,
   maintb.real_synth_ind,
   maintb.is_equiv_ind,
   maintb.what_if_ind,
   maintb.bus_date,
   maintb.p_s_ind,
   maintb.dist_qty,
   maintb.alloc_qty,
   maintb.discount_qty,
   maintb.priced_qty,
   maintb.qty_uom_code,
   maintb.qty_uom_code_conv_to,
   maintb.qty_uom_conv_rate,
   maintb.price_curr_code_conv_to,
   maintb.price_curr_conv_rate,
   maintb.price_uom_code_conv_to,
   maintb.price_uom_conv_rate,
   maintb.spread_pos_group_num,
   maintb.delivered_qty,
   maintb.open_pl,
   maintb.pl_asof_date,
   maintb.closed_pl,
   maintb.addl_cost_sum,
   maintb.sec_conversion_factor,
   maintb.sec_qty_uom_code,
   maintb.commkt_key,
   maintb.trading_prd,
   maintb.trans_id,
   null,
   maintb.estimate_qty,
   maintb.formula_num,
   maintb.formula_body_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.trade_item_dist maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.dist_num,
   audtb.trade_num,
   audtb.order_num,
   audtb.item_num,
   audtb.accum_num,
   audtb.qpp_num,
   audtb.pos_num,
   audtb.real_port_num,
   audtb.dist_type,
   audtb.real_synth_ind,
   audtb.is_equiv_ind,
   audtb.what_if_ind,
   audtb.bus_date,
   audtb.p_s_ind,
   audtb.dist_qty,
   audtb.alloc_qty,
   audtb.discount_qty,
   audtb.priced_qty,
   audtb.qty_uom_code,
   audtb.qty_uom_code_conv_to,
   audtb.qty_uom_conv_rate,
   audtb.price_curr_code_conv_to,
   audtb.price_curr_conv_rate,
   audtb.price_uom_code_conv_to,
   audtb.price_uom_conv_rate,
   audtb.spread_pos_group_num,
   audtb.delivered_qty,
   audtb.open_pl,
   audtb.pl_asof_date,
   audtb.closed_pl,
   audtb.addl_cost_sum,
   audtb.sec_conversion_factor,
   audtb.sec_qty_uom_code,
   audtb.commkt_key,
   audtb.trading_prd,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.estimate_qty,
   audtb.formula_num,
   audtb.formula_body_num,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_trade_item_dist audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_tid_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_tid_all_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_tid_all_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_tid_all_rs', NULL, NULL
GO
