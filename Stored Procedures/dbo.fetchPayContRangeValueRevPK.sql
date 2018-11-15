SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                                                         
CREATE proc [dbo].[fetchPayContRangeValueRevPK] 
(                                                 
   @asof_trans_id      int,                                                              
   @oid                int        
)   
as                                                                                       
set nocount on                                                                           
declare @trans_id   int                                                                  
                                                                                         
select @trans_id = trans_id                                                              
from dbo.pay_cont_range_value                                                                       
where oid = @oid                                                                         
                                                                                         
if @trans_id <= @asof_trans_id                                                           
begin                                                                                    
   select   
	  application,
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  deduction,
	  oid,
	  pay_range_def_oid1,
	  pay_range_def_oid2,
	  percentage,
	  price_rule_oid,
	  resp_trans_id = null,
	  trans_id
   from dbo.pay_cont_range_value                                                                    
   where oid = @oid                                                                      
end                                                                                      
else                                                                                     
begin                                                                                    
   set rowcount 1                                                                        
   select
	  application,
	  asof_trans_id = @asof_trans_id,
	  cp_formula_oid,
	  deduction,
	  oid,
	  pay_range_def_oid1,
	  pay_range_def_oid2,
	  percentage,
	  price_rule_oid,
	  resp_trans_id,
	  trans_id
   from dbo.aud_pay_cont_range_value                                                                
   where oid = @oid and                                                                  
         trans_id <= @asof_trans_id and                                                  
         resp_trans_id > @asof_trans_id                                                  
   order by trans_id desc                                                                
end                                                                                      
return                                                                                   
GO
GRANT EXECUTE ON  [dbo].[fetchPayContRangeValueRevPK] TO [next_usr]
GO
