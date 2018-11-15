SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchQpOptionRevPK]      
(                                            
   @asof_trans_id      int,                                                              
   @oid                int  
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.qp_option                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  asof_trans_id = @asof_trans_id,
	  commkt_key,
	  cp_formula_oid,
	  formula_string,
	  oid,
	  price_rule_oid,
	  quote_index,
	  quote_point,
	  quote_source_code,
	  resp_trans_id = null,
	  trading_prd,
	  trans_id
   from dbo.qp_option                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  asof_trans_id = @asof_trans_id,
	  commkt_key,
	  cp_formula_oid,
	  formula_string,
	  oid,
	  price_rule_oid,
	  quote_index,
	  quote_point,
	  quote_source_code,
	  resp_trans_id = null,
	  trading_prd,
	  trans_id
   from dbo.aud_qp_option                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchQpOptionRevPK] TO [next_usr]
GO
