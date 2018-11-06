SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_POSGRID_risk_position]                    
(
   trader_init,                           
   contr_date, 
   trade_num,                         
   trade_key,                         
   counterparty,                            
   order_type_code,                               
   inhouse_ind,                            
   pos_type_desc,                         
   trading_entity,                      
   port_group_tag,                    
   profit_center,            
   real_port_num,                            
   dist_num,                        
   pos_num, 
   cmdty_group,                       
   cmdty_code, 
   cmdty_short_name,                        
   mkt_code,        
   mkt_short_name,             
   commkt_key,                           
   trading_prd,
   pos_type,                       
   position_p_s_ind,                        
   pos_qty_uom_code,                         
   primary_pos_qty,                        
   secondary_qty_uom_code,                             
   secondary_pos_qty,                        
   is_equiv_ind,                                     
   contract_p_s_ind,                               
   contract_qty_uom_code,                            
   contract_qty,                         
   mtm_price_source_code,                          
   is_hedge_ind,                                
   grid_position_month,                        
   grid_position_qtr,                        
   grid_position_year,
   trading_prd_desc,                        
   last_issue_date,                        
   last_trade_date,                        
   trade_mod_date,                         
   trade_creation_date,                        
   trans_id,                    
   trading_entity_num,     
   pricing_risk_date,                    
   product,                    
   order_num,          
   item_num)                                                
as                                          
select distinct 
   ti.trader_init, 
   ti.contr_date, 
   tid.trade_num,                         
   cast(tid.trade_num as varchar) + '/' + 
       cast(tid.order_num as varchar) + '/' + 
         cast(tid.item_num as varchar),
   a1.acct_short_name,        /* counteryparty */                 
   ti.order_type_code,                         
   ti.inhouse_ind,   
   p.pos_type_desc,                      
   a2.acct_short_name,        /* trading entity */
   p.risk_group_code,
   p.profit_center_code,                        
   tid.real_port_num,
   tid.dist_num,
   p.pos_num,
   p.parent_cmdty_code,       /* cmdty_group */
   p.cmdty_code,
   c.cmdty_short_name,
   p.mkt_code,        
   m.mkt_short_name,                 
   p.commkt_key,                 
   p.trading_prd, 
   p.pos_type,
   tid.p_s_ind,  
   isnull(tid.qty_uom_code_conv_to, tid.qty_uom_code),               /* 'PrimaryQtyUOM' */                        
   case when tid.p_s_ind = 'P' then 1 
        else -1 
   end * (dist_qty - alloc_qty) * isnull(tid.qty_uom_conv_rate, 1),  /* 'PrimaryPosQty' */                                          
   case when tid.sec_qty_uom_code = tid.qty_uom_code_conv_to then tid.qty_uom_code  
        else tid.sec_qty_uom_code 
   end,                                                              /* 'secondary_qty_uom_code' */                       
   case when tid.p_s_ind = 'P' then 1 
        else -1 
   end * isnull((dist_qty - alloc_qty) * 
            (case when tid.sec_qty_uom_code = tid.qty_uom_code_conv_to then 1 
                  else isnull(tid.qty_uom_conv_rate, 1) * isnull(tid.sec_conversion_factor, 1)
             end), 0),                                               /* 'SecondaryPosQty' */                                        
   p.is_equiv_ind,
   ti.p_s_ind,                                                       /* 'contract_p_s_ind' */
   ti.contr_qty_uom_code, 
   ti.contr_qty,  
   p.mtm_price_source_code,                         
   p.is_hedge_ind,                   
   substring(datename(mm, p.last_issue_date), 1, 3),                        
   'Q' + convert(char, datename(q, p.last_issue_date)),                        
   datename(yyyy, p.last_issue_date), 
   p.trading_prd_desc,                       
   p.last_issue_date,                        
   p.last_trade_date,                        
   ti.trade_mod_date,                         
   ti.creation_date, 
   p.trans_id, 
   p.trading_entity_num,                    
   isnull(acc.quote_end_date, p.last_issue_date),                   /* PriceRiskDate */ 
   ti.product,
   tid.order_num,          
   tid.item_num                                               
from dbo.v_POSGRID_trade_item_info ti
        LEFT OUTER JOIN dbo.account a1 with (nolock)
           ON ti.acct_num = a1.acct_num,                    
     dbo.v_POSGRID_position_info p
        LEFT OUTER JOIN dbo.account a2 with (nolock)
           ON p.booking_comp_num = a2.acct_num  
        LEFT OUTER JOIN dbo.commodity c with (nolock)
           ON p.cmdty_code = c.cmdty_code
        LEFT OUTER JOIN dbo.market m with (nolock)
           ON p.mkt_code = m.mkt_code,                             
     dbo.trade_item_dist tid with (nolock)                    
        LEFT OUTER JOIN dbo.accumulation acc with (nolock) 
           ON tid.trade_num = acc.trade_num and 
              tid.order_num = acc.order_num and 
              tid.item_num = acc.item_num and 
              tid.accum_num = acc.accum_num 
where tid.trade_num = ti.trade_num and 
      tid.order_num = ti.order_num and 
      tid.item_num = ti.item_num and
      tid.pos_num = p.pos_num and 
      round(tid.dist_qty - tid.alloc_qty, 2) <> 0
union                                          
select distinct 
   i.trader_init, 
   i.contr_date, 
   i.trade_num,                         
   cast(i.trade_num as varchar) + '/' + cast(i.order_num as varchar) 
      + '/' + cast(i.item_num as varchar) + '/' + cast(i.inv_num as varchar),  
   a1.acct_short_name,             /* counterparty */           
   'STORAGE',                      /* order_type_code */   
   'N',                            /* inhouse_ind */
   p.pos_type_desc,  
   a2.acct_short_name,             /* trading_entity */
   p.risk_group_code,
   p.profit_center_code,                        
   p.real_port_num,
   i.inv_num,
   p.pos_num,
   p.parent_cmdty_code,            /* cmdty_group */
   p.cmdty_code,
   c.cmdty_short_name,
   p.mkt_code,        
   m.mkt_short_name,                 
   p.commkt_key, 
   p.trading_prd,
   p.pos_type,
   'P',                           /* p_s_ind */                        
   p.qty_uom_code, 
   (p.long_qty - p.short_qty),                      
   p.sec_pos_uom_code, 
   (p.sec_long_qty - p.sec_short_qty),                      
   p.is_equiv_ind,
   'P',                          /* contract_p_s_ind */
   p.qty_uom_code,  
   (p.long_qty - short_qty),     /* contract_qty */                        
   p.mtm_price_source_code,                         
   p.is_hedge_ind,                        
   substring(datename(mm, p.last_issue_date), 1, 3),                        
   'Q' + convert(char, datename(q, p.last_issue_date)),                        
   datename(yyyy, p.last_issue_date),       
   p.trading_prd_desc,                 
   p.last_issue_date,
   p.last_trade_date,                        
   i.creation_date,                         
   i.creation_date, 
   p.trans_id, 
   p.trading_entity_num,                 
   p.last_issue_date,                    
   NULL,
   0,
   0                     
from dbo.v_POSGRID_inv_position_info p
        LEFT OUTER JOIN dbo.account a2 with (nolock)
           ON p.booking_comp_num = a2.acct_num  
        LEFT OUTER JOIN dbo.commodity c with (nolock)
           ON p.cmdty_code = c.cmdty_code
        LEFT OUTER JOIN dbo.market m with (nolock)
           ON p.mkt_code = m.mkt_code,                            
     (select max(ti.trade_num) trade_num, 
             max(ti.order_num) order_num, 
             max(ti.item_num) item_num,
             max(inv.inv_num) inv_num,
             max(t.trader_init) trader_init, 
             max(t.contr_date) contr_date, 
             max(t.acct_num) acct_num, 
             inv.pos_num, 
             max(creation_date) creation_date 
      from dbo.trade_item ti with (nolock),
           dbo.trade t with (nolock),
           dbo.inventory inv with (nolock)                       
      where ti.trade_num = inv.trade_num and 
            ti.order_num = inv.order_num and 
            ti.item_num = inv.sale_item_num and 
            ti.trade_num = t.trade_num                        
      group by inv.pos_num) i                                            
        LEFT OUTER JOIN dbo.account a1 with (nolock)
           ON i.acct_num = a1.acct_num                    
where i.pos_num = p.pos_num
GO
GRANT SELECT ON  [dbo].[v_POSGRID_risk_position] TO [next_usr]
GO
