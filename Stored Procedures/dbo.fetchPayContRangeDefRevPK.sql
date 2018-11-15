SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[fetchPayContRangeDefRevPK] 
(                                                 
   @asof_trans_id      int,                                                              
   @oid                int     
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int   
                                                               
select @trans_id = trans_id                                                              
from dbo.pay_cont_range_def                                                                       
where oid = @oid    
                                                                     
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  commkt_key,
	  cp_formula_oid,
	  dim_num,
	  oid,
	  per_spec_uom,
	  price_rule_oid,
	  price_source_code,
	  price_type,
	  resp_trans_id = null,
	  spec_code,
	  spec_from_value,
	  spec_to_value,
	  spec_uom_code,
	  trans_id
   from dbo.pay_cont_range_def                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select                                                                                
	  asof_trans_id = @asof_trans_id,
	  commkt_key,
	  cp_formula_oid,
	  dim_num,
	  oid,
	  per_spec_uom,
	  price_rule_oid,
	  price_source_code,
	  price_type,
	  resp_trans_id = null,
	  spec_code,
	  spec_from_value,
	  spec_to_value,
	  spec_uom_code,
	  trans_id
   from dbo.aud_pay_cont_range_def                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchPayContRangeDefRevPK] TO [next_usr]
GO
