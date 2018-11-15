SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pay_rule_fixprice_info_rev] 
(
	oid,
	cp_formula_oid,
	price_rule_oid,
	spec_from_value,
	spec_to_value,
	fixed_price,
	fixed_price_basis,
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
	fixed_price,
	fixed_price_basis,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_pay_rule_fixprice_info
GO
GRANT SELECT ON  [dbo].[v_pay_rule_fixprice_info_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_pay_rule_fixprice_info_rev] TO [next_usr]
GO
