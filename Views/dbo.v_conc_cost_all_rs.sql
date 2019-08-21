SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_cost_all_rs]
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
as
select
	cc.oid,
	cc.owner_code,
	cc.conc_contract_oid,
	cc.contract_execution_oid,
	cc.contract_exec_detail_oid,
	cc.strategy_execution_oid,
	cc.strategy_execution_detail_oid,
	cc.conc_ref_cost_item_oid,
	cc.cost_basis,
	cc.exp_rev_ind,
	cc.cost_unit_price,
	cc.cost_price_curr_code,
	cc.cost_cmnt_num,
	cc.comment,	
	cc.trans_id,
	null	
from dbo.conc_cost cc
        left outer join dbo.icts_transaction it
           on cc.trans_id = it.trans_id
union
select
	acc.oid,
	acc.owner_code,
	acc.conc_contract_oid,
	acc.contract_execution_oid,
	acc.contract_exec_detail_oid,
	acc.strategy_execution_oid,
	acc.strategy_execution_detail_oid,
	acc.conc_ref_cost_item_oid,
	acc.cost_basis,
	acc.exp_rev_ind,
	acc.cost_unit_price,
	acc.cost_price_curr_code,
	acc.cost_cmnt_num,
	acc.comment,	
	acc.trans_id,
	acc.resp_trans_id
from dbo.aud_conc_cost acc
        left outer join dbo.icts_transaction it
           on acc.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_cost_all_rs] TO [next_usr]
GO
