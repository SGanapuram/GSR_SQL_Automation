SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pay_rule_fixprice_info_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	fixed_price,
	fixed_price_basis,
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
	pa.spec_from_value,
	pa.spec_to_value,
	pa.fixed_price,
	pa.fixed_price_basis,
	pa.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.pay_rule_fixprice_info pa 
        left outer join dbo.icts_transaction it 
           on pa.trans_id = it.trans_id 
union 
select 
	pa.oid,
	pa.cp_formula_oid,
	pa.price_rule_oid,
	pa.spec_from_value,
	pa.spec_to_value,
	pa.fixed_price,
	pa.fixed_price_basis,
	pa.trans_id,
	pa.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_pay_rule_fixprice_info pa 
        left outer join dbo.icts_transaction it 
           on pa.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_pay_rule_fixprice_info_all_rs] TO [next_usr]
GO
