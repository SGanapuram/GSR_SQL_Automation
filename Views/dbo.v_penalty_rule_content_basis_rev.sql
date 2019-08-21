SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_penalty_rule_content_basis_rev] 
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
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	inc_dec_value,
	penalty_charge,
	floor_or_ceiling_basis,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_penalty_rule_content_basis
GO
GRANT SELECT ON  [dbo].[v_penalty_rule_content_basis_rev] TO [next_usr]
GO
