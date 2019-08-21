SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pricing_rule_rev]
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
	asof_trans_id,
	resp_trans_id
)
as
select 
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
	trans_id,
	resp_trans_id
from dbo.aud_pricing_rule 
GO
GRANT SELECT ON  [dbo].[v_pricing_rule_rev] TO [next_usr]
GO
