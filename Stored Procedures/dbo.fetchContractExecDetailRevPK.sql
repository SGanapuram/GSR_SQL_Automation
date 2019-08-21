SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchContractExecDetailRevPK]  
(                                    
   @asof_trans_id      bigint,                                      
   @oid                int    
)   
as                                                               
set nocount on                                                   
declare @trans_id   bigint                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.contract_exec_detail                                            
where oid = @oid                             
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  assay_group_num,
	  conc_del_item_oid,
	  contract_execution_oid,
	  exec_qty,
	  exec_qty_uom_code,
	  obj_key1,
	  obj_key2,
	  obj_key3,
	  object_type,
	  oid,
	  resp_trans_id = null,
	  trans_id
   from dbo.contract_exec_detail                                         
   where oid = @oid                          
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  assay_group_num,
	  conc_del_item_oid,
	  contract_execution_oid,
	  exec_qty,
	  exec_qty_uom_code,
	  obj_key1,
	  obj_key2,
	  obj_key3,
	  object_type,
	  oid,
	  resp_trans_id = null,
	  trans_id
   from dbo.aud_contract_exec_detail                                      
   where oid = @oid and                      
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchContractExecDetailRevPK] TO [next_usr]
GO
