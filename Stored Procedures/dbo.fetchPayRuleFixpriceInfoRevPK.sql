SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchPayRuleFixpriceInfoRevPK] 
(                                                 
   @asof_trans_id      int,                                                              
   @oid                int 
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.pay_rule_fixprice_info                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  fixed_price,
	  fixed_price_basis,
	  oid,
	  price_rule_oid,
	  resp_trans_id = null,
	  spec_from_value,
	  spec_to_value,
	  trans_id
   from dbo.pay_rule_fixprice_info                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  fixed_price,
	  fixed_price_basis,
	  oid,
	  price_rule_oid,
	  resp_trans_id = null,
	  spec_from_value,
	  spec_to_value,
	  trans_id
   from dbo.aud_pay_rule_fixprice_info                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchPayRuleFixpriceInfoRevPK] TO [next_usr]
GO
