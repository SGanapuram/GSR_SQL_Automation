SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_tc_rule_escalator_price_base_all_rs] 
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
	tc.oid,
	tc.cp_formula_oid,
	tc.price_rule_oid,
	tc.from_value,
	tc.to_value,
	tc.inc_dec_ind,
	tc.inc_dec_value,
	tc.floor_or_ceiling_value,
	tc.app_ind,
	tc.tc_value,
	tc.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.tc_rule_escalator_price_base tc 
        left outer join dbo.icts_transaction it 
           on tc.trans_id = it.trans_id 
union 
select
	tc.oid,
	tc.cp_formula_oid,
	tc.price_rule_oid,
	tc.from_value,
	tc.to_value,
	tc.inc_dec_ind,
	tc.inc_dec_value,
	tc.floor_or_ceiling_value,
	tc.app_ind,
	tc.tc_value,
	tc.trans_id,
	tc.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_tc_rule_escalator_price_base tc 
        left outer join dbo.icts_transaction it 
           on tc.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_tc_rule_escalator_price_base_all_rs] TO [next_usr]
GO
