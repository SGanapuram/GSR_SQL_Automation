SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_exch_opt_rev]
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
   strike_price,                   
   strike_price_uom_code,          
   strike_price_curr_code,         
   exp_date,                       
   exp_zone_code,                  
   total_fill_qty,                 
   fill_qty_uom_code,              
   avg_fill_price,                 
   strike_excer_date,              
   clr_brkr_num,                   
   clr_brkr_cont_num,              
   clr_brkr_comm_amt,              
   clr_brkr_comm_curr_code,        
   clr_brkr_comm_uom_code,         
   clr_brkr_ref_num,  
   surrender_qty, 
   use_in_fifo_ind,
   exec_type_code,
   price_source_code,
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
   strike_price,                   
   strike_price_uom_code,          
   strike_price_curr_code,         
   exp_date,                       
   exp_zone_code,                  
   total_fill_qty,                 
   fill_qty_uom_code,              
   avg_fill_price,                 
   strike_excer_date,              
   clr_brkr_num,                   
   clr_brkr_cont_num,              
   clr_brkr_comm_amt,              
   clr_brkr_comm_curr_code,        
   clr_brkr_comm_uom_code,         
   clr_brkr_ref_num,               
   surrender_qty,             
   use_in_fifo_ind,
   exec_type_code,
   price_source_code,
   trans_id,                       
   trans_id,                       
   resp_trans_id
from dbo.aud_trade_item_exch_opt
GO
GRANT SELECT ON  [dbo].[v_trade_item_exch_opt_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_exch_opt_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_exch_opt_rev', NULL, NULL
GO