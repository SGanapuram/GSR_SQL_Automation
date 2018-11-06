SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_otc_opt_rev]
(
   trade_num,                      
   order_num,                      
   item_num,                       
   put_call_ind,                   
   opt_type,                       
   settlement_type,                
   premium,                        
   premium_uom_code,               
   premium_curr_code,              
   premium_pay_date,               
   credit_term_code,               
   strike_price,                   
   strike_price_uom_code,          
   strike_price_curr_code,         
   price_date_from,                
   price_date_to,                  
   apo_special_cond_code,          
   exp_date,                       
   exp_zone_code,                  
   lookback_cond_code,             
   lookback_last_date,             
   strike_excer_date,              
   pay_term_code,                  
   desired_opt_eval_method,
   desired_otc_opt_code,
   trans_id,
   asof_trans_id,                       
   resp_trans_id
)
as
select 
   trade_num,                      
   order_num,                      
   item_num,                       
   put_call_ind,                   
   opt_type,                       
   settlement_type,                
   premium,                        
   premium_uom_code,               
   premium_curr_code,              
   premium_pay_date,               
   credit_term_code,               
   strike_price,                   
   strike_price_uom_code,          
   strike_price_curr_code,         
   price_date_from,                
   price_date_to,                  
   apo_special_cond_code,          
   exp_date,                       
   exp_zone_code,                  
   lookback_cond_code,             
   lookback_last_date,             
   strike_excer_date,              
   pay_term_code,                  
   desired_opt_eval_method,
   desired_otc_opt_code,
   trans_id,                       
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_otc_opt
GO
GRANT SELECT ON  [dbo].[v_trade_item_otc_opt_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_otc_opt_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_otc_opt_rev', NULL, NULL
GO
