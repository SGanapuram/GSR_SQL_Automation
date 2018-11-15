SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_tc_flat_benchmark_all_rs] 
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
	tc_value,
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
	tc.oid,
	tc.cp_formula_oid,
	tc.price_rule_oid,
	tc.flat_amt,
	tc.flat_percentage,
	tc.app_to_flat,
	tc.benchmark_detail_oid,
	tc.benchmark_value,
	tc.benchmark_percentage,
	tc.app_to_benchmark,
	tc.tc_value,
	tc.from_value,
	tc.to_value,
	tc.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.tc_flat_benchmark tc 
        left outer join dbo.icts_transaction it 
           on tc.trans_id = it.trans_id 
union 
select 
	tc.oid,
	tc.cp_formula_oid,
	tc.price_rule_oid,
	tc.flat_amt,
	tc.flat_percentage,
	tc.app_to_flat,
	tc.benchmark_detail_oid,
	tc.benchmark_value,
	tc.benchmark_percentage,
	tc.app_to_benchmark,
	tc.tc_value,
	tc.from_value,
	tc.to_value,	
	tc.trans_id,
	tc.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_tc_flat_benchmark tc 
        left outer join dbo.icts_transaction it 
           on tc.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_tc_flat_benchmark_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_tc_flat_benchmark_all_rs] TO [next_usr]
GO
