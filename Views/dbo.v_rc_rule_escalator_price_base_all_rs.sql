SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_rc_rule_escalator_price_base_all_rs] 
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
	rc_value,
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
	rc.oid,
	rc.cp_formula_oid,
	rc.price_rule_oid,
	rc.from_value,
	rc.to_value,
	rc.inc_dec_ind,
	rc.inc_dec_value,
	rc.floor_or_ceiling_value,
	rc.app_ind,
	rc.rc_value,
	rc.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.rc_rule_escalator_price_base rc 
        left outer join dbo.icts_transaction it 
           on rc.trans_id = it.trans_id 
union 
select 
	rc.oid,
	rc.cp_formula_oid,
	rc.price_rule_oid,
	rc.from_value,
	rc.to_value,
	rc.inc_dec_ind,
	rc.inc_dec_value,
	rc.floor_or_ceiling_value,
	rc.app_ind,
	rc.rc_value,
	rc.trans_id,
	rc.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_rc_rule_escalator_price_base rc 
        left outer join dbo.icts_transaction it 
           on rc.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_rc_rule_escalator_price_base_all_rs] TO [next_usr]
GO
