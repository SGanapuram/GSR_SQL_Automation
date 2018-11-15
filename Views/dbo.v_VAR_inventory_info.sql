SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_VAR_inventory_info]     
(  
   trade_num,   
   order_num,   
   item_num,  
   inv_num,  
   trader_init,   
   contr_date,   
   acct_num,   
   pos_num,   
   creation_date,  
   creator_init,  
   item_type,  
   del_date_to,  
   formula_ind,  
   inv_qty,  
   inv_qty_uom_code,  
   open_close_ind,   
   inv_type,  
   booking_comp_num  
)  
as  
select  
   ti.trade_num,   
   ti.order_num,   
   ti.item_num,  
   inv.inv_num,  
   t.trader_init,   
   t.contr_date,   
   t.acct_num,   
   inv.pos_num,   
   t.creation_date,  
   t.creator_init,  
   ti.item_type,  
   tiwp.del_date_to,  
   ti.formula_ind,  
   case when pre_inv.open_close_ind in ('O', 'o')   
           then  
              isnull(inv.inv_cnfrmd_qty, 0) + isnull(inv.inv_adj_qty, 0)  
        else  
           isnull(inv.inv_cnfrmd_qty, 0) + isnull(inv.inv_adj_qty, 0) +   
              isnull(inv.inv_open_prd_proj_qty, 0) + isnull(inv.inv_open_prd_actual_qty, 0)  
   end,  
   inv.inv_qty_uom_code,  
   inv.open_close_ind,   
   inv.inv_type,  
   ti.booking_comp_num   
from (select inv1.inv_num,  
             inv1.trade_num,  
             inv1.order_num,  
             inv1.sale_item_num,  
             inv1.pos_num,  
             inv1.inv_cnfrmd_qty,  
             inv1.inv_adj_qty,  
             inv1.inv_open_prd_proj_qty,  
             inv1.inv_open_prd_actual_qty,  
             inv1.inv_qty_uom_code,  
             inv1.open_close_ind,   
             inv1.inv_type,  
             inv1.prev_inv_num   
      from (select ROW_NUMBER() OVER (PARTITION BY trade_num, order_num, sale_item_num   
                                      ORDER BY trade_num desc, order_num desc, sale_item_num desc) as ord,  
                   trade_num,   
                   order_num,   
                   sale_item_num  
            from dbo.inventory) inv  
               INNER JOIN dbo.inventory inv1  
                  ON inv.trade_num = inv1.trade_num and  
                     inv.order_num = inv1.order_num and  
                     inv.sale_item_num = inv1.sale_item_num  
            where inv.ord = 1) inv  
        LEFT OUTER JOIN dbo.inventory pre_inv   
           ON inv.prev_inv_num = pre_inv.inv_num   
        INNER JOIN dbo.trade_item ti  
           ON ti.trade_num = inv.trade_num and   
              ti.order_num = inv.order_num and   
              ti.item_num = inv.sale_item_num   
        INNER JOIN dbo.trade t  
           ON ti.trade_num = t.trade_num  
        LEFT OUTER JOIN dbo.account a1 WITH (NOLOCK)   
           ON a1.acct_num = t.acct_num  
        LEFT OUTER JOIN dbo.trade_item_wet_phy tiwp  
           ON ti.trade_num = tiwp.trade_num and  
              ti.order_num = tiwp.order_num and  
              ti.item_num = tiwp.item_num  
GO
GRANT SELECT ON  [dbo].[v_VAR_inventory_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_inventory_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_inventory_info', NULL, NULL
GO
