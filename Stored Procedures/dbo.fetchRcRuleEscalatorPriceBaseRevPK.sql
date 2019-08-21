SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchRcRuleEscalatorPriceBaseRevPK] 
(                                                 
   @asof_trans_id      bigint,                                                              
   @oid                int     
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   bigint                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.rc_rule_escalator_price_base                                                                       
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
	  rc_value,
	  resp_trans_id = null,
	  to_value,
	  trans_id
   from dbo.rc_rule_escalator_price_base                                                                    
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
	  rc_value,
	  resp_trans_id = null,
	  to_value,
	  trans_id
   from dbo.aud_rc_rule_escalator_price_base                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchRcRuleEscalatorPriceBaseRevPK] TO [next_usr]
GO
