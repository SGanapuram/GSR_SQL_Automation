SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchFixedPriceContentBasisRevPK]                                                  
   @asof_trans_id      int,                                                              
   @oid      int                                                                         
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.fixed_price_content_basis                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select                                                                                
	  app_ind,
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  fixed_pricing_basis,
	  floor_or_ceiling_value,
	  inc_dec_ind,
	  inc_dec_value,
	  oid,
	  price,
	  price_rule_oid,
	  resp_trans_id = null,
	  spec_from_value,
	  spec_to_value,
	  trans_id
   from dbo.fixed_price_content_basis                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  app_ind,
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  fixed_pricing_basis,
	  floor_or_ceiling_value,
	  inc_dec_ind,
	  inc_dec_value,
	  oid,
	  price,
	  price_rule_oid,
	  resp_trans_id,
	  spec_from_value,
	  spec_to_value,
	  trans_id
   from dbo.aud_fixed_price_content_basis                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchFixedPriceContentBasisRevPK] TO [next_usr]
GO
