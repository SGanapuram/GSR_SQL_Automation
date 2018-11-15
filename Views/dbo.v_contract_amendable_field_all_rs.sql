SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_contract_amendable_field_all_rs]
(
	oid,
	entity_id,
	entity_field,
	entity_field_datatype,
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
	con.oid,
	con.entity_id,
	con.entity_field,
	con.entity_field_datatype,
	con.trans_id,
	null,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                
from dbo.contract_amendable_field con                              
        left outer join dbo.icts_transaction it                      
           on con.trans_id = it.trans_id                    
union                                                            
select
	con.oid,
	con.entity_id,
	con.entity_field,
	con.entity_field_datatype,
	con.trans_id,
	con.resp_trans_id,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                  
from dbo.aud_contract_amendable_field con                           
        left outer join dbo.icts_transaction it                      
           on con.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_contract_amendable_field_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_contract_amendable_field_all_rs] TO [next_usr]
GO
