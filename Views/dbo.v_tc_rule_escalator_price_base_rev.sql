SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_tc_rule_escalator_price_base_rev] 
(
	oid,
	cp_formula_oid,
	price_rule_oid,
	from_value,
	to_value,
	inc_dec_ind,
	inc_dec_value,
	floor_or_ceiling_value,
	app_ind,
	tc_value,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	cp_formula_oid,
	price_rule_oid,
	from_value,
	to_value,
	inc_dec_ind,
	inc_dec_value,
	floor_or_ceiling_value,
	app_ind,
	tc_value,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_tc_rule_escalator_price_base
GO
GRANT SELECT ON  [dbo].[v_tc_rule_escalator_price_base_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_tc_rule_escalator_price_base_rev] TO [next_usr]
GO
