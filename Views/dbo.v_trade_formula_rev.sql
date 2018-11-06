SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_formula_rev]
(
   trade_num,                      
   order_num,                      
   item_num,                       
   formula_num,                    
   fall_back_ind,                  
   fall_back_to_formula_num,       
   formula_qty_opt,                
   trans_id,                       
   asof_trans_id,                     
   resp_trans_id
)
as
select
   trade_num,
   order_num,                      
   item_num,                       
   formula_num,                    
   fall_back_ind,                  
   fall_back_to_formula_num,       
   formula_qty_opt,                
   trans_id,                       
   trans_id,                       
   resp_trans_id
from dbo.aud_trade_formula
GO
GRANT SELECT ON  [dbo].[v_trade_formula_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_formula_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_formula_rev', NULL, NULL
GO
