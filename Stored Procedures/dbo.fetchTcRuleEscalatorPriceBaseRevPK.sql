SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchTcRuleEscalatorPriceBaseRevPK]
(                                                  
   @asof_trans_id      int,                                                              
   @oid                int       
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.tc_rule_escalator_price_base                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select
	  app_ind,
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  floor_or_ceiling_value,
	  from_value,
	  inc_dec_ind,
	  inc_dec_value,
	  oid,
	  price_rule_oid,
	  resp_trans_id = null,
	  tc_value,
	  to_value,
	  trans_id
   from dbo.tc_rule_escalator_price_base                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  app_ind,
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  floor_or_ceiling_value,
	  from_value,
	  inc_dec_ind,
	  inc_dec_value,
	  oid,
	  price_rule_oid,
	  resp_trans_id,
	  tc_value,
	  to_value,
	  trans_id
   from dbo.aud_tc_rule_escalator_price_base                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end 
                                                                                     
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchTcRuleEscalatorPriceBaseRevPK] TO [next_usr]
GO
