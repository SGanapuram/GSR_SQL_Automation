SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchContractPricingFormulaRevPK]  
(                                                
   @asof_trans_id      int,                                                              
   @oid                int       
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.contract_pricing_formula                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  conc_contract_oid,
	  oid,
	  resp_trans_id = null,
	  trans_id,
	  use_ind
   from dbo.contract_pricing_formula                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  asof_trans_id = @asof_trans_id,
	  conc_contract_oid,
	  oid,
	  resp_trans_id,
	  trans_id,
	  use_ind
   from dbo.aud_contract_pricing_formula                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchContractPricingFormulaRevPK] TO [next_usr]
GO
