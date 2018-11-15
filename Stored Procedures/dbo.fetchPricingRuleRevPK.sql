SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchPricingRuleRevPK]                                                  
   @asof_trans_id      int,                                                              
   @oid      int                                                                         
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.pricing_rule                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  asof_trans_id = @asof_trans_id,
	  base_value,
	  cp_formula_oid,
	  curr_code,
	  max_charge,
	  max_content,
	  min_charge,
	  min_content,
	  oid,
	  parent_pricing_rule_oid,
	  per_spec_uom_code,
	  price_basis,
	  qp_decl_option_ind,
	  resp_trans_id = null,
	  rule_direction_ind,
	  rule_type_ind,
	  spec_code,
	  spec_uom_code,
	  trans_id,
	  use_ind
   from dbo.pricing_rule                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  asof_trans_id = @asof_trans_id,
	  base_value,
	  cp_formula_oid,
	  curr_code,
	  max_charge,
	  max_content,
	  min_charge,
	  min_content,
	  oid,
	  parent_pricing_rule_oid,
	  per_spec_uom_code,
	  price_basis,
	  qp_decl_option_ind,
	  resp_trans_id,
	  rule_direction_ind,
	  rule_type_ind,
	  spec_code,
	  spec_uom_code,
	  trans_id,
	  use_ind
   from dbo.aud_pricing_rule                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchPricingRuleRevPK] TO [next_usr]
GO
