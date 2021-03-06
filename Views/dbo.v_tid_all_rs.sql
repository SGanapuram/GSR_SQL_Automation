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
	estimate_qty,
	formula_num,
	formula_body_num,
	parcel_num,
	parent_dist_num,
	int_value,
	float_value,
	string_value,
	resp_trans_id,
	trans_id,
	trans_type,
	trans_user_init,
	tran_date,
	app_name,
	workstation_id,
	sequence,
	equiv_source_ind,
	spec_code,
	exec_inv_num
)
as
select
	tid.dist_num,
	tid.trade_num,
	tid.order_num,
	tid.item_num,
	tid.accum_num,
	tid.qpp_num,
	tid.pos_num,
	tid.real_port_num,
	tid.dist_type,
	tid.real_synth_ind,
	tid.is_equiv_ind,
	tid.what_if_ind,
	tid.bus_date,
	tid.p_s_ind,
	tid.dist_qty,
	tid.alloc_qty,
	tid.discount_qty,
	tid.priced_qty,
	tid.qty_uom_code,
	tid.qty_uom_code_conv_to,
	tid.qty_uom_conv_rate,
	tid.price_curr_code_conv_to,
	tid.price_curr_conv_rate,
	tid.price_uom_code_conv_to,
	tid.price_uom_conv_rate,
	tid.spread_pos_group_num,
	tid.delivered_qty,
	tid.open_pl,
	tid.pl_asof_date,
	tid.closed_pl,
	tid.addl_cost_sum,
	tid.sec_conversion_factor,
	tid.sec_qty_uom_code,
	tid.commkt_key,
	tid.trading_prd,
	tid.estimate_qty,
	tid.formula_num,
	tid.formula_body_num,
	tid.parcel_num,
	tid.parent_dist_num,
	tid.int_value,
	tid.float_value,
	tid.string_value,
	null,
	tid.trans_id,
	it.type,
	it.user_init,
	it.tran_date,
	it.app_name,
	it.workstation_id,
	it.sequence,
	tid.equiv_source_ind,
	tid.spec_code,
	tid.exec_inv_num
from dbo.trade_item_dist tid
        left outer join dbo.icts_transaction it
           on tid.trans_id = it.trans_id
union
select
	tid.dist_num,
	tid.trade_num,
	tid.order_num,
	tid.item_num,
	tid.accum_num,
	tid.qpp_num,
	tid.pos_num,
	tid.real_port_num,
	tid.dist_type,
	tid.real_synth_ind,
	tid.is_equiv_ind,
	tid.what_if_ind,
	tid.bus_date,
	tid.p_s_ind,
	tid.dist_qty,
	tid.alloc_qty,
	tid.discount_qty,
	tid.priced_qty,
	tid.qty_uom_code,
	tid.qty_uom_code_conv_to,
	tid.qty_uom_conv_rate,
	tid.price_curr_code_conv_to,
	tid.price_curr_conv_rate,
	tid.price_uom_code_conv_to,
	tid.price_uom_conv_rate,
	tid.spread_pos_group_num,
	tid.delivered_qty,
	tid.open_pl,
	tid.pl_asof_date,
	tid.closed_pl,
	tid.addl_cost_sum,
	tid.sec_conversion_factor,
	tid.sec_qty_uom_code,
	tid.commkt_key,
	tid.trading_prd,
	tid.estimate_qty,
	tid.formula_num,
	tid.formula_body_num,
	tid.parcel_num,
	tid.parent_dist_num,
	tid.int_value,
	tid.float_value,
	tid.string_value,
	tid.resp_trans_id,
	tid.trans_id,
	it.type,
	it.user_init,
	it.tran_date,
	it.app_name,
	it.workstation_id,
	it.sequence,
	tid.equiv_source_ind,
	tid.spec_code,
	tid.exec_inv_num
from dbo.aud_trade_item_dist tid
        left outer join dbo.icts_transaction it
           on tid.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_tid_all_rs] TO [next_usr]
GO
