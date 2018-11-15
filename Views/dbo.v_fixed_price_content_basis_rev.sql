SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fixed_price_content_basis_rev] 
(
	oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	inc_dec_ind,
	inc_dec_value,
	floor_or_ceiling_value,
	app_ind,
	price,
	fixed_pricing_basis,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select 
    oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	inc_dec_ind,
	inc_dec_value,
	floor_or_ceiling_value,
	app_ind,
	price,
	fixed_pricing_basis,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_fixed_price_content_basis
GO
GRANT SELECT ON  [dbo].[v_fixed_price_content_basis_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fixed_price_content_basis_rev] TO [next_usr]
GO
