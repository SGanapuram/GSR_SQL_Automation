SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_contract_pricing_formula_rev] 
(
	oid,
	conc_contract_oid,
	use_ind,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	conc_contract_oid,
	use_ind,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_contract_pricing_formula
GO
GRANT SELECT ON  [dbo].[v_contract_pricing_formula_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_contract_pricing_formula_rev] TO [next_usr]
GO
