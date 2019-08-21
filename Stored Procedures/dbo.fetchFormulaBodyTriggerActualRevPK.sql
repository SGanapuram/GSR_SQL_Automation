SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                 
CREATE proc [dbo].[fetchFormulaBodyTriggerActualRevPK] 
(                                     
   @asof_trans_id      	bigint,                                     
   @trigger_actual_num  int
)
as                                                               
set nocount on                                                   
declare @trans_id   bigint                                          
                                                                 
select @trans_id = trans_id                                      
from dbo.formula_body_trigger_actual                                            
where @trigger_actual_num = trigger_actual_num			
	                                                               
if @trans_id <= @asof_trans_id                                   
begin                                                            
   select                                                        
	  actual_triggered_pcnt,
	  actual_triggered_qty,
      actual_triggered_qty_uom_code,
      ai_est_actual_num,
      alloc_item_num,
      alloc_num,
      applied_trigger_pcnt,
      applied_trigger_qty,
      applied_trigger_qty_uom_code,
      formula_body_num,
      formula_num,
      fully_triggered,
      parcel_num,
      trans_id,
      trigger_actual_num,
      trigger_num,
      trigger_rem_bal
   from dbo.formula_body_trigger_actual                                         
   where @trigger_actual_num = trigger_actual_num 	                         
end                                                              
else                                                             
begin                                                            
   select top 1                                                      
	  actual_triggered_pcnt,
	  actual_triggered_qty,
	  actual_triggered_qty_uom_code,
	  ai_est_actual_num,
	  alloc_item_num,
	  alloc_num,
	  applied_trigger_pcnt,
	  applied_trigger_qty,
	  applied_trigger_qty_uom_code,
	  formula_body_num,
	  formula_num,
	  fully_triggered,
	  parcel_num,
	  trans_id,
	  trigger_actual_num,
	  trigger_num,
	  trigger_rem_bal
   from dbo.aud_formula_body_trigger_actual                                      
   where trigger_actual_num = @trigger_actual_num and			                    
		 trans_id <= @asof_trans_id and                         
		 resp_trans_id > @asof_trans_id                          
   order by trans_id desc                                        
end                                                              
return                                                           
GO
GRANT EXECUTE ON  [dbo].[fetchFormulaBodyTriggerActualRevPK] TO [next_usr]
GO
