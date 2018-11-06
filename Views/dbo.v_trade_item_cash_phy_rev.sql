SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_cash_phy_rev]
(
  trade_num,                      
  order_num,                      
  item_num,                       
  min_qty,                   
  min_qty_uom_code,                       
  max_qty,                
  max_qty_uom_code,                        
  total_settled_qty,               
  settled_qty_uom_code,              
  credit_term_code,               
  pay_days,               
  pay_term_code,                   
  trade_imp_rec_ind,          
  trade_exp_rec_ind,         
  margin_conv_factor,                
  cfd_swap_ind,                  
  efs_ind, 
  execution_date,
  trans_id,
  asof_trans_id,                       
  resp_trans_id
)
as
select 
  trade_num,                      
  order_num,                      
  item_num,                       
  min_qty,                   
  min_qty_uom_code,                       
  max_qty,                
  max_qty_uom_code,                        
  total_settled_qty,               
  settled_qty_uom_code,              
  credit_term_code,               
  pay_days,               
  pay_term_code,                   
  trade_imp_rec_ind,          
  trade_exp_rec_ind,         
  margin_conv_factor,                
  cfd_swap_ind,                  
  efs_ind,
  execution_date,
  trans_id,
  trans_id,                      
  resp_trans_id
from dbo.aud_trade_item_cash_phy
GO
GRANT SELECT ON  [dbo].[v_trade_item_cash_phy_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_cash_phy_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_cash_phy_rev', NULL, NULL
GO
