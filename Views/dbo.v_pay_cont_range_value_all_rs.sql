SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pay_cont_range_value_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	pay_range_def_oid1,
	pay_range_def_oid2,
	percentage,
	deduction,
	application,
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
	pa.oid,
	pa.cp_formula_oid,
	pa.price_rule_oid,
	pa.pay_range_def_oid1,
	pa.pay_range_def_oid2,
	pa.percentage,
	pa.deduction,
	pa.application,
	pa.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.pay_cont_range_value pa 
        left outer join dbo.icts_transaction it 
           on pa.trans_id = it.trans_id 
union 
select 
	pa.oid,
	pa.cp_formula_oid,
	pa.price_rule_oid,
	pa.pay_range_def_oid1,
	pa.pay_range_def_oid2,
	pa.percentage,
	pa.deduction,
	pa.application,
	pa.trans_id,
	pa.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_pay_cont_range_value pa 
        left outer join dbo.icts_transaction it 
           on pa.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_pay_cont_range_value_all_rs] TO [next_usr]
GO
