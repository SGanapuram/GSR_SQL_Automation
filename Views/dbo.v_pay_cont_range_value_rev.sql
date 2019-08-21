SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pay_cont_range_value_rev] 
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
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	cp_formula_oid,
	price_rule_oid,
	pay_range_def_oid1,
	pay_range_def_oid2,
	percentage,
	deduction,
	application,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_pay_cont_range_value
GO
GRANT SELECT ON  [dbo].[v_pay_cont_range_value_rev] TO [next_usr]
GO
