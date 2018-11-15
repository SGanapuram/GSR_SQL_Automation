SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchContractExecutionRevPK]                                      
   @asof_trans_id      int,                                      
   @oid      int                                       
as                                                               
set nocount on                                                   
declare @trans_id   int                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.contract_execution                                            
where oid = @oid                             
                                                                 
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  conc_contract_oid,
	  custom_exec_num,
	  exec_purch_sale_ind,
	  exec_status,
	  flat_amt_curr_code,
	  oid,
	  parent_exec_id,
	  pcnt_factor,
	  prorated_flat_amt,
	  real_port_num,	
	  resp_trans_id = null,
	  trans_id
   from dbo.contract_execution                                         
   where oid = @oid                          
end                                                              
else                                                             
begin                                                            
   set rowcount 1                                                
   select                                                        
	  asof_trans_id = @asof_trans_id,
	  conc_contract_oid,
	  custom_exec_num,
	  exec_purch_sale_ind,
	  exec_status,
	  flat_amt_curr_code,
	  oid,
	  parent_exec_id,
	  pcnt_factor,
	  prorated_flat_amt,
	  real_port_num,
	  resp_trans_id,
	  trans_id
   from dbo.aud_contract_execution                                      
   where oid = @oid and                      
         trans_id <= @asof_trans_id and                          
         resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchContractExecutionRevPK] TO [next_usr]
GO
