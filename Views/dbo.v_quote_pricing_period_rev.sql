SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_quote_pricing_period_rev]
(
   trade_num,
   order_num,
   item_num,
   accum_num,                      
   qpp_num,                        
   formula_num,                    
   formula_body_num,               
   formula_comp_num,               
   real_trading_prd,               
   risk_trading_prd,               
   nominal_start_date,             
   nominal_end_date,               
   quote_start_date,               
   quote_end_date,                 
   num_of_pricing_days,            
   num_of_days_priced,             
   total_qty,                      
   priced_qty,                     
   qty_uom_code,                   
   priced_price,                   
   open_price,                     
   price_curr_code,                
   price_uom_code,                 
   last_pricing_date,              
   manual_override_ind, 
   cal_impact_start_date,
   cal_impact_end_date,
   calendar_code,         
   trans_id,  
   asof_trans_id,                     
   resp_trans_id 
)
as
select
   trade_num,                      
   order_num,                      
   item_num,                       
   accum_num,                      
   qpp_num,                        
   formula_num,                    
   formula_body_num,               
   formula_comp_num,               
   real_trading_prd,               
   risk_trading_prd,               
   nominal_start_date,             
   nominal_end_date,               
   quote_start_date,               
   quote_end_date,                 
   num_of_pricing_days,            
   num_of_days_priced,             
   total_qty,                      
   priced_qty,                     
   qty_uom_code,                   
   priced_price,                   
   open_price,                     
   price_curr_code,                
   price_uom_code,                 
   last_pricing_date,              
   manual_override_ind,            
   cal_impact_start_date,
   cal_impact_end_date,
   calendar_code,         
   trans_id,                       
   trans_id,                      
   resp_trans_id 
from dbo.aud_quote_pricing_period
GO
GRANT SELECT ON  [dbo].[v_quote_pricing_period_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_quote_pricing_period_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_quote_pricing_period_rev', NULL, NULL
GO