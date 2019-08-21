SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_qp_period_rev] 
(
	oid,
	qp_option_oid,
	time_unit,
	time_frame,
	app_cond,	
	trigger_desc,
	description,
	default_ind,
	avg_time_unit,
	avg_time_frame,
	trigger_event,	
	trigger_event_desc,	
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	qp_option_oid,
	time_unit,
	time_frame,
	app_cond,	
	trigger_desc,
	description,
	default_ind,
	avg_time_unit,
	avg_time_frame,
	trigger_event,	
	trigger_event_desc,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_qp_period

GO
GRANT SELECT ON  [dbo].[v_qp_period_rev] TO [next_usr]
GO
