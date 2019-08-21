SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_rc_flat_benchmark_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	flat_amt,
	flat_percentage,
	app_to_flat,
	benchmark_detail_oid,
	benchmark_value,
	benchmark_percentage,
	app_to_benchmark,
	rc_value,
	from_value,
	to_value,	
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
	rc.oid,
	rc.cp_formula_oid,
	rc.price_rule_oid,
	rc.flat_amt,
	rc.flat_percentage,
	rc.app_to_flat,
	rc.benchmark_detail_oid,
	rc.benchmark_value,
	rc.benchmark_percentage,
	rc.app_to_benchmark,
	rc.rc_value,
	rc.from_value,
	rc.to_value,	
	rc.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.rc_flat_benchmark rc 
        left outer join dbo.icts_transaction it 
           on rc.trans_id = it.trans_id 
union 
select 
	rc.oid,
	rc.cp_formula_oid,
	rc.price_rule_oid,
	rc.flat_amt,
	rc.flat_percentage,
	rc.app_to_flat,
	rc.benchmark_detail_oid,
	rc.benchmark_value,
	rc.benchmark_percentage,
	rc.app_to_benchmark,
	rc.rc_value,
	rc.from_value,
	rc.to_value,	
	rc.trans_id,
	rc.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_rc_flat_benchmark rc 
        left outer join dbo.icts_transaction it 
           on rc.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_rc_flat_benchmark_all_rs] TO [next_usr]
GO
