SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_phys_inv_time_sheet_all_rs]
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
	phy.oid,
	phy.exec_inv_num,
	phy.logistic_event_order_num,
	phy.logistic_event,
	phy.loc_code,
	phy.mot_code,
	phy.document_id,
	phy.event_from_date,
	phy.from_date_actual_ind,
	phy.event_to_date,
	phy.to_date_actual_ind,
	phy.short_comment,
	phy.cmnt_num,
	phy.spec_code,
	phy.trans_id,
	null,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                
from dbo.phys_inv_time_sheet phy                              
    left outer join dbo.icts_transaction it                      
        on phy.trans_id = it.trans_id                    
union                                                            
select                                                           
	phy.oid,
	phy.exec_inv_num,
	phy.logistic_event_order_num,
	phy.logistic_event,
	phy.loc_code,
	phy.mot_code,
	phy.document_id,
	phy.event_from_date,
	phy.from_date_actual_ind,
	phy.event_to_date,
	phy.to_date_actual_ind,
	phy.short_comment,
	phy.cmnt_num,
	phy.spec_code,
	phy.trans_id,
	phy.resp_trans_id,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                               
from dbo.aud_phys_inv_time_sheet phy                           
    left outer join dbo.icts_transaction it                      
        on phy.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_phys_inv_time_sheet_all_rs] TO [next_usr]
GO
