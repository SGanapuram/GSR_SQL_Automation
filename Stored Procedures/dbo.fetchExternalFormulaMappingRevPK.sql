SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchExternalFormulaMappingRevPK]                                                  
   @asof_trans_id      int,                                                              
   @oid      int                                                                         
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.external_formula_mapping                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  asof_trans_id = @asof_trans_id,
	  commkt_key,
	  oid,
	  per_spec_uom_code,
	  price_point,
	  price_source,
	  quote_string,
	  resp_trans_id = null,
      spec_code,	
      spec_uom_code,	
	  trans_id,
	  ui_formula_str,
	  ui_index,
	  ui_point,
	  ui_source	
   from dbo.external_formula_mapping
   where oid = @oid
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  asof_trans_id = @asof_trans_id,
	  commkt_key,
	  oid,
	  per_spec_uom_code,
	  price_point,
	  price_source,
	  quote_string,
	  resp_trans_id,
      spec_code,
      spec_uom_code,	
	  trans_id,
	  ui_formula_str,
	  ui_index,
	  ui_point,
	  ui_source	
   from dbo.aud_external_formula_mapping                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchExternalFormulaMappingRevPK] TO [next_usr]
GO
