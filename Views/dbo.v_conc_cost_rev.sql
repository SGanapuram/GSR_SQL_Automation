SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_cost_rev]
(
	oid,
	owner_code,
	conc_contract_oid,
	contract_execution_oid,
	contract_exec_detail_oid,
	strategy_execution_oid,
	strategy_execution_detail_oid,
	conc_ref_cost_item_oid,
	cost_basis,
	exp_rev_ind,
	cost_unit_price,
	cost_price_curr_code,
	cost_cmnt_num,
	comment,
	trans_id,
	resp_trans_id
)
as select
	oid,
	owner_code,
	conc_contract_oid,
	contract_execution_oid,
	contract_exec_detail_oid,
	strategy_execution_oid,
	strategy_execution_detail_oid,
	conc_ref_cost_item_oid,
	cost_basis,
	exp_rev_ind,
	cost_unit_price,
	cost_price_curr_code,
	cost_cmnt_num,
	comment,
	trans_id,
	resp_trans_id
from dbo.aud_conc_cost
GO
GRANT SELECT ON  [dbo].[v_conc_cost_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_cost_rev] TO [next_usr]
GO
