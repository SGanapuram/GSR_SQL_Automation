SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pricing_rule_all_rs] 
(
	oid,
	cp_formula_oid,
	spec_code,
	spec_uom_code,
	per_spec_uom_code,
	base_value,
	use_ind,
	rule_type_ind,
	curr_code,
	price_basis,
	min_charge,
	max_charge,
	max_content,
	min_content,
	rule_direction_ind,
	qp_decl_option_ind,
	parent_pricing_rule_oid,
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
	pr.oid,
	pr.cp_formula_oid,
	pr.spec_code,
	pr.spec_uom_code,
	pr.per_spec_uom_code,
	pr.base_value,
	pr.use_ind,
	pr.rule_type_ind,
	pr.curr_code,
	pr.price_basis,
	pr.min_charge,
	pr.max_charge,
	pr.max_content,
	pr.min_content,
	pr.rule_direction_ind,
	pr.qp_decl_option_ind,
	pr.parent_pricing_rule_oid,
	pr.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.pricing_rule pr 
        left outer join dbo.icts_transaction it 
           on pr.trans_id = it.trans_id 
union 
select 
	pr.oid,
	pr.cp_formula_oid,
	pr.spec_code,
	pr.spec_uom_code,
	pr.per_spec_uom_code,
	pr.base_value,
	pr.use_ind,
	pr.rule_type_ind,
	pr.curr_code,
	pr.price_basis,
	pr.min_charge,
	pr.max_charge,
	pr.max_content,
	pr.min_content,
	pr.rule_direction_ind,
	pr.qp_decl_option_ind,
	pr.parent_pricing_rule_oid,
	pr.trans_id,
	pr.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_pricing_rule pr 
        left outer join dbo.icts_transaction it 
           on pr.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_pricing_rule_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_pricing_rule_all_rs] TO [next_usr]
GO
