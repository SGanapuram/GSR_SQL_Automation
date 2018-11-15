SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchContractAmendableFieldRevPK]
(                                      
   @asof_trans_id      int,                                      
   @oid                int    
)   
as                                                               
set nocount on                                                   
declare @trans_id   int                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.contract_amendable_field                                            
where oid = @oid                             
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
		asof_trans_id = @asof_trans_id,
		entity_field,
		entity_field_datatype,
		entity_id,
		oid,
		resp_trans_id = null,
		trans_id
   from dbo.contract_amendable_field                                         
   where oid = @oid                          
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
		asof_trans_id = @asof_trans_id,
		entity_field,
		entity_field_datatype,
		entity_id,
		oid,
		resp_trans_id = null,
		trans_id
   from dbo.aud_contract_amendable_field                                      
   where oid = @oid and                      
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchContractAmendableFieldRevPK] TO [next_usr]
GO
