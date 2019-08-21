SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_contract_pricing_formula_all_rs] 
( 
	oid,
	conc_contract_oid,
	use_ind,
	trans_id,
	resp_trans_id, 
	trans_type, 
	trans_user_init, 
	tran_date, 
	app_name, 
	workstation_id, 
	sequence 
) 
as 
select 
	co.oid,
	co.conc_contract_oid,
	co.use_ind,
	co.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.contract_pricing_formula co 
        left outer join dbo.icts_transaction it 
           on co.trans_id = it.trans_id 
union 
select 
	co.oid,
	co.conc_contract_oid,
	co.use_ind,
	co.trans_id,
	co.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_contract_pricing_formula co 
        left outer join dbo.icts_transaction it 
           on co.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_contract_pricing_formula_all_rs] TO [next_usr]
GO
