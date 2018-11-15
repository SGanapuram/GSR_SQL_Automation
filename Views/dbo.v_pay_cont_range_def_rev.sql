SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pay_cont_range_def_rev] 
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
	asof_trans_id,
	resp_trans_id
)
as
select oid,
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
	trans_id,
	resp_trans_id
from dbo.aud_pay_cont_range_def
GO
GRANT SELECT ON  [dbo].[v_pay_cont_range_def_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_pay_cont_range_def_rev] TO [next_usr]
GO
