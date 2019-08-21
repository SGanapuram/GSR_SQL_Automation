SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
CREATE view [dbo].[v_contract_exec_detail_rev]                              
(                                                        
	oid,
	object_type,
	obj_key1,
	obj_key2,
	obj_key3,
	contract_execution_oid,
	conc_del_item_oid,
	trans_id,
	asof_trans_id,
	resp_trans_id,
	assay_group_num,
	exec_qty,
	exec_qty_uom_code
)                                                        
as                                                       
select                                                   
	oid,
	object_type,
	obj_key1,
	obj_key2,
	obj_key3,
	contract_execution_oid,
	conc_del_item_oid,
	trans_id,
	trans_id,
	resp_trans_id,
	assay_group_num,
	exec_qty,
	exec_qty_uom_code	
from dbo.aud_contract_exec_detail                                 
GO
GRANT SELECT ON  [dbo].[v_contract_exec_detail_rev] TO [next_usr]
GO
