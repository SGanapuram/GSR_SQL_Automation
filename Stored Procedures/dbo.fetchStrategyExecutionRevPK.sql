SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchStrategyExecutionRevPK] 
(                                     
   @asof_trans_id      bigint,                                      
   @oid                int      
)   
as                                                               
set nocount on                                                   
declare @trans_id   bigint                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.strategy_execution                                            
where oid = @oid                             
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	  alloc_num,
	  asof_trans_id = @asof_trans_id,
	  max_strategy_detail_num,
	  oid,
	  real_port_num,
	  resp_trans_id = null,
	  shipment_num,
	  strategy_status,
	  trans_id
   from dbo.strategy_execution                                         
   where oid = @oid                          
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
	  alloc_num,
	  asof_trans_id = @asof_trans_id,
	  max_strategy_detail_num,
	  oid,
	  real_port_num,
	  resp_trans_id = null,
	  shipment_num,
	  strategy_status,
	  trans_id
   from dbo.aud_strategy_execution                                      
   where oid = @oid and                      
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchStrategyExecutionRevPK] TO [next_usr]
GO
