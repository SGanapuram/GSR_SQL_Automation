SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_qp_option_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	quote_index,
	commkt_key,
	quote_source_code,
	quote_point,
	formula_string,
	trading_prd,
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
	qp.oid,
	qp.cp_formula_oid,
	qp.price_rule_oid,
	qp.quote_index,
	qp.commkt_key,
	qp.quote_source_code,
	qp.quote_point,
	qp.formula_string,
	qp.trading_prd,
	qp.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.qp_option qp 
        left outer join dbo.icts_transaction it 
           on qp.trans_id = it.trans_id 
union 
select 
	qp.oid,
	qp.cp_formula_oid,
	qp.price_rule_oid,
	qp.quote_index,
	qp.commkt_key,
	qp.quote_source_code,
	qp.quote_point,
	qp.formula_string,
	qp.trading_prd,
	qp.trans_id,
	qp.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_qp_option qp 
        left outer join dbo.icts_transaction it 
           on qp.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_qp_option_all_rs] TO [next_usr]
GO
