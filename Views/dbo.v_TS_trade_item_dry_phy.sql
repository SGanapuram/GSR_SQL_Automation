SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_trade_item_dry_phy]     
(     
   trade_num,     
   order_num,     
   item_num,    
   tol_qty,     
   tol_qty_uom_code,     
   tol_sign,  
   tol_opt,  
   min_qty, max_qty,     
   density_ind,     
   credit_term_code,    
   pay_days,     
   pay_term_code,     
   del_term_code,     
   mot_code,     
   mot_full_name,     
   del_loc_code,    
   transportation,     
   lc_required,     
   del_date_from,     
   del_date_to,     
   del_loc_name,    
   credit_approver_init,     
   credit_approval_date,     
   trans_id     
)    
as    
select     
   trade_num,    
   order_num,    
   item_num,    
   tol_qty,    
   tol_qty_uom_code,    
   tol_sign,  
   tol_opt,  
   min_qty,    
   max_qty,    
   density_ind,    
   credit_term_code,    
   pay_days,    
   pay_term_code,    
   del_term_code,    
   tidp.mot_code,    
   m.mot_full_name,    
   del_loc_code,    
   transportation,    
   CASE WHEN credit_term_code IN ('DOCLC', 'SBLC') THEN 'Y'    
           ELSE 'N'    
   END,    
   del_date_from,    
   del_date_to,    
   loc.loc_name,    
   credit_approver_init,    
   credit_approval_date,    
   tidp.trans_id    
from dbo.trade_item_dry_phy tidp    
        LEFT OUTER JOIN dbo.mot m WITH (nolock)    
           ON tidp.mot_code = m.mot_code    
        LEFT OUTER JOIN dbo.location loc WITH (nolock)    
           ON tidp.del_loc_code = loc.loc_code      

GO
GRANT SELECT ON  [dbo].[v_TS_trade_item_dry_phy] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_trade_item_dry_phy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_trade_item_dry_phy', NULL, NULL
GO
