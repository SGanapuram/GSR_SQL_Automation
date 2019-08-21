SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
create view [dbo].[v_phys_inv_time_sheet_rev]                              
(                                                      
	oid,
	exec_inv_num,
	logistic_event_order_num,
	logistic_event,
	loc_code,
	mot_code,
	document_id,
	event_from_date,
	from_date_actual_ind,
	event_to_date,
	to_date_actual_ind,
	short_comment,
	cmnt_num,
	spec_code,
	trans_id,
	asof_trans_id,
	resp_trans_id
)                                                        
as                                                       
select                                                   
	oid,
	exec_inv_num,
	logistic_event_order_num,
	logistic_event,
	loc_code,
	mot_code,
	document_id,
	event_from_date,
	from_date_actual_ind,
	event_to_date,
	to_date_actual_ind,
	short_comment,
	cmnt_num,
	spec_code,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_phys_inv_time_sheet                                 
GO
GRANT SELECT ON  [dbo].[v_phys_inv_time_sheet_rev] TO [next_usr]
GO
