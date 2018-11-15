SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_penalty_rule_content_basis_all_rs] 
( 
	oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	inc_dec_value,
	penalty_charge,
	floor_or_ceiling_basis,
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
	pe.oid,
	pe.cp_formula_oid,
	pe.price_rule_oid,
	pe.spec_from_value,
	pe.spec_to_value,
	pe.inc_dec_value,
	pe.penalty_charge,
	pe.floor_or_ceiling_basis,
	pe.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.penalty_rule_content_basis pe 
        left outer join dbo.icts_transaction it 
           on pe.trans_id = it.trans_id 
union 
select
	pe.oid,
	pe.cp_formula_oid,
	pe.price_rule_oid,
	pe.spec_from_value,
	pe.spec_to_value,
	pe.inc_dec_value,
	pe.penalty_charge,
	pe.floor_or_ceiling_basis,
	pe.trans_id,
	pe.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_penalty_rule_content_basis pe 
        left outer join dbo.icts_transaction it 
           on pe.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_penalty_rule_content_basis_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_penalty_rule_content_basis_all_rs] TO [next_usr]
GO
