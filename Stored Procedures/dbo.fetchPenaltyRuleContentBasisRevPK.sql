SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchPenaltyRuleContentBasisRevPK] 
(                                                 
   @asof_trans_id      int,                                                              
   @oid                int
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.penalty_rule_content_basis                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  floor_or_ceiling_basis,
	  inc_dec_value,
	  oid,
	  penalty_charge,
	  price_rule_oid,
	  resp_trans_id = null,
	  spec_from_value,
	  spec_to_value,
	  trans_id
   from dbo.penalty_rule_content_basis                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  floor_or_ceiling_basis,
	  inc_dec_value,
	  oid,
	  penalty_charge,
	  price_rule_oid,
	  resp_trans_id = null,
	  spec_from_value,
	  spec_to_value,
	  trans_id
   from dbo.aud_penalty_rule_content_basis                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchPenaltyRuleContentBasisRevPK] TO [next_usr]
GO
