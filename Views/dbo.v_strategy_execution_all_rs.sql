SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_strategy_execution_all_rs]
(
	oid,
	real_port_num,
	shipment_num,
	alloc_num,
	strategy_status,
	max_strategy_detail_num,
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
	str.oid,
	str.real_port_num,
	str.shipment_num,
	str.alloc_num,
	str.strategy_status,
	str.max_strategy_detail_num,
	str.trans_id,
	null,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                              
from dbo.strategy_execution str                              
        left outer join dbo.icts_transaction it                      
           on str.trans_id = it.trans_id                    
union                                                            
select                                                           
	str.oid,
	str.real_port_num,
	str.shipment_num,
	str.alloc_num,
	str.strategy_status,
	str.max_strategy_detail_num,
	str.trans_id,
	str.resp_trans_id,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                  
from dbo.aud_strategy_execution str                           
        left outer join dbo.icts_transaction it                      
           on str.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_strategy_execution_all_rs] TO [next_usr]
GO
