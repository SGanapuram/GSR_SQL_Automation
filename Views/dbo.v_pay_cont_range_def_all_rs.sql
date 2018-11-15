SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pay_cont_range_def_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	dim_num,
	spec_code,
	spec_uom_code,
	per_spec_uom,
	spec_from_value,
	spec_to_value,
	commkt_key,
	price_source_code,
	price_type,
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
	pa.dim_num,
	pa.spec_code,
	pa.spec_uom_code,
	pa.per_spec_uom,
	pa.spec_from_value,
	pa.spec_to_value,
	pa.commkt_key,
	pa.price_source_code,
	pa.price_type,
	pa.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.pay_cont_range_def pa 
        left outer join dbo.icts_transaction it 
           on pa.trans_id = it.trans_id 
union 
select
	pa.oid,
	pa.cp_formula_oid,
	pa.price_rule_oid,
	pa.dim_num,
	pa.spec_code,
	pa.spec_uom_code,
	pa.per_spec_uom,
	pa.spec_from_value,
	pa.spec_to_value,
	pa.commkt_key,
	pa.price_source_code,
	pa.price_type,
	pa.trans_id,
	pa.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_pay_cont_range_def pa 
        left outer join dbo.icts_transaction it 
           on pa.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_pay_cont_range_def_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_pay_cont_range_def_all_rs] TO [next_usr]
GO
