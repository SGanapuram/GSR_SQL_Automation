SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[v_qp_period_all_rs] 
( 
	oid,
	qp_option_oid,
	time_unit,
	time_frame,
	app_cond,	
	default_ind,
	avg_time_unit,
	avg_time_frame,
	trigger_event,	
	trigger_event_desc,	
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
	qp.oid,
	qp.qp_option_oid,
	qp.time_unit,
	qp.time_frame,
	qp.app_cond,	
	qp.default_ind,
	qp.avg_time_unit,
	qp.avg_time_frame,
	qp.trigger_event,	
	qp.trigger_event_desc,	
	qp.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.qp_period qp 
 left outer join dbo.icts_transaction it 
 on qp.trans_id = it.trans_id 
union 
select
	qp.oid,
	qp.qp_option_oid,
	qp.time_unit,
	qp.time_frame,
	qp.app_cond,	
	qp.default_ind,
	qp.avg_time_unit,
	qp.avg_time_frame,
	qp.trigger_event,	
	qp.trigger_event_desc,	
	qp.trans_id,
	qp.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_qp_period qp 
 left outer join dbo.icts_transaction it 
 on qp.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_qp_period_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_qp_period_all_rs] TO [next_usr]
GO
