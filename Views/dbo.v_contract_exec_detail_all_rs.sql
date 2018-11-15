SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_contract_exec_detail_all_rs]
(
	oid,
	object_type,
	obj_key1,
	obj_key2,
	obj_key3,
	contract_execution_oid,
	conc_del_item_oid,
	trans_id,	
	resp_trans_id,
	assay_group_num,
	exec_qty,
	exec_qty_uom_code,
	trans_type,
	trans_user_init,  
	tran_date,   
	app_name,   
	workstation_id,  
	sequence                                           
)                                                                
as                                                               
select
	con.oid,
	con.object_type,
	con.obj_key1,
	con.obj_key2,
	con.obj_key3,
	con.contract_execution_oid,
	con.conc_del_item_oid,
	con.trans_id,	
	null,
	con.assay_group_num,
	con.exec_qty,
	con.exec_qty_uom_code,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                  
from dbo.contract_exec_detail con                              
        left outer join dbo.icts_transaction it                      
           on con.trans_id = it.trans_id                    
union                                                            
select
	con.oid,
	con.object_type,
	con.obj_key1,
	con.obj_key2,
	con.obj_key3,
	con.contract_execution_oid,
	con.conc_del_item_oid,
	con.trans_id,
	con.resp_trans_id,
	con.assay_group_num,
	con.exec_qty,
	con.exec_qty_uom_code,	
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                
from dbo.aud_contract_exec_detail con                           
        left outer join dbo.icts_transaction it                      
           on con.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_contract_exec_detail_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_contract_exec_detail_all_rs] TO [next_usr]
GO
