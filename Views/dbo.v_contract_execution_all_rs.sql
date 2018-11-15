SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_contract_execution_all_rs]
(
	oid,
	exec_purch_sale_ind,
	parent_exec_id,
	pcnt_factor,
	exec_status,
	real_port_num,
	custom_exec_num,	
	conc_contract_oid,
	trans_id,
	resp_trans_id,
	trans_type,
	trans_user_init,
	prorated_flat_amt,
	flat_amt_curr_code,
	tran_date,   
	app_name,   
	workstation_id,  
	sequence                                                      
)                                                                
as                                                               
select
	con.oid,
	con.exec_purch_sale_ind,
	con.parent_exec_id,
	con.pcnt_factor,
	con.exec_status,
	con.real_port_num,
	con.custom_exec_num,	
	con.conc_contract_oid,
	con.prorated_flat_amt,
	con.flat_amt_curr_code,	
	con.trans_id,
	null,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                   
from dbo.contract_execution con                              
        left outer join dbo.icts_transaction it                      
           on con.trans_id = it.trans_id                    
union                                                            
select
	con.oid,
	con.exec_purch_sale_ind,
	con.parent_exec_id,
	con.pcnt_factor,
	con.exec_status,
	con.real_port_num,
	con.custom_exec_num,	
	con.conc_contract_oid,
	con.prorated_flat_amt,
	con.flat_amt_curr_code,	
	con.trans_id,
	con.resp_trans_id,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                 
from dbo.aud_contract_execution con                           
        left outer join dbo.icts_transaction it                      
           on con.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_contract_execution_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_contract_execution_all_rs] TO [next_usr]
GO
