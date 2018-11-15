SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_VAR_financial_position]     
(  
   trade_num,           
   order_num,  
   item_num,           
   trader_init,           
   contr_date,           
   counterparty,           
   order_type_code,           
   inhouse_ind,           
   pos_type_desc,          
   trading_entity,          
   book,          
   profit_center,          
   real_port_num,          
   dist_num,          
   pos_num,          
   cmdty_group,           
   cmdty_code,          
   cmdty_short_name,           
   mkt_code,           
   mkt_short_name,   
   mkt_type,         
   commkt_key,           
   trading_prd,          
   pos_type,           
   tid_p_s_ind,   
   dist_qty,  
   alloc_qty,  
   tid_qty_uom_code,  
   tid_qty_uom_code_conv_to,  
   tid_qty_uom_conv_rate,  
   tid_price_curr_conv_to,  
   tid_price_curr_conv_rate,  
   is_equiv_ind,          
   contract_p_s_ind,          
   contract_qty_uom_code,           
   contract_qty,           
   mtm_price_source_code,           
   is_hedge_ind,          
   trading_prd_desc,          
   first_del_date,  
   last_del_date,  
   last_issue_date,          
   last_trade_date,          
   trade_mod_date,           
   trade_creation_date,          
   trans_id,      
   trading_entity_num,        
   price_risk_date,      
   product,      
   phy_curr_code,   
   phy_price_uom_code,  
   phy_price_source_code,   
   fut_curr_code,   
   fut_price_uom_code,   
   fut_price_source_code,  
   price_curr_code,  
   price_uom_code,  
   creator_init,  
   option_type,  
   opt_exp_date,  
   opt_start_date,  
   settlement_type,  
   put_call_ind,  
   strike_price,  
   strike_price_curr_code,  
   strike_price_uom_code,  
   item_type,  
   del_date_to,  
   dist_type,  
   formula_ind,  
   pos_qty_uom_code,  
   price_source_code,  
   booking_comp_num,   
   open_close_ind,   
   inv_type  
)                 
as          
select distinct   
   tid.trade_num,    
   tid.order_num,   
   tid.item_num,  
   ti.trader_init,   
   ti.contr_date,   
   ti.counterparty,  
   ti.order_type_code,           
   ti.inhouse_ind,   
   dbo.udf_position_type_desc(p.pos_type, p.option_type, p.is_hedge_ind, p.is_equiv_ind),          
   p.booking_company_num,  
   p.group_code,  
   p.profit_center_code,          
   tid.real_port_num,  
   tid.dist_num,  
   p.pos_num,  
   p.parent_cmdty_code,   
   p.cmdty_code,  
   p.cmdty_short_name,   
   p.mkt_code,           
   p.mkt_short_name,  
   p.mkt_type,  
   p.commkt_key,   
   p.trading_prd,  
   p.pos_type,           
   tid.p_s_ind,   
   tid.dist_qty,  
   tid.alloc_qty,  
   tid.qty_uom_code,  
   tid.qty_uom_code_conv_to,  
   tid.qty_uom_conv_rate,  
   tid.price_curr_code_conv_to,  
   tid.price_curr_conv_rate,  
   p.is_equiv_ind,  
   ti.contract_p_s_ind,  
   ti.contr_qty_uom_code,   
   ti.contr_qty,  
   p.mtm_price_source_code,           
   p.is_hedge_ind,          
   p.trading_prd_desc,        
   p.first_del_date,  
   p.last_del_date,  
   p.last_issue_date,          
   p.last_trade_date,          
   ti.trade_mod_date,           
   ti.creation_date,   
   p.trans_id,   
   p.trading_entity_num,      
   isnull(ti.quote_end_date, p.last_issue_date),   
   ti.product,    
   p.phy_commkt_curr_code,   
   p.phy_commkt_price_uom_code,  
   p.phy_sec_price_source_code,   
   p.fut_commkt_curr_code,   
   p.fut_commkt_price_uom_code,   
   p.fut_sec_price_source_code,  
   p.price_curr_code,  
   p.price_uom_code,  
   ti.creator_init,  
   p.option_type,  
   p.opt_exp_date,  
   p.opt_start_date,  
   p.settlement_type,  
   p.put_call_ind,  
   p.strike_price,  
   p.strike_price_curr_code,  
   p.strike_price_uom_code,  
   ti.item_type,  
   ti.del_date_to,  
   tid.dist_type,  
   ti.formula_ind,  
   p.qty_uom_code,  
   case when p.mtm_price_source_code is not null   
           then p.mtm_price_source_code  
        else (case when p.mkt_type = 'P' then p.phy_sec_price_source_code  
                   else p.fut_sec_price_source_code  
              end)  
   end,  
   ti.booking_comp_num,  
   '?', /* open_close_ind */   
   '?'  /* inv_type */   
from (select dist_num,  
             trade_num,   
             order_num,   
             item_num,  
             accum_num,  
             real_port_num,  
             pos_num,  
             p_s_ind,    
             qty_uom_code,  
             qty_uom_code_conv_to,  
             qty_uom_conv_rate,  
             price_curr_code_conv_to,  
             price_curr_conv_rate,  
             dist_qty,   
             alloc_qty,   
             sec_qty_uom_code,   
             sec_conversion_factor,  
             dist_type  
       from dbo.trade_item_dist d  
       where /* 1 = (case when p_s_ind = 'S'   
                          then (case when (alloc_qty - dist_qty) > 0.0 then 1  
                                     else 0  
                                end)  
                       else (case when (dist_qty - alloc_qty) > 0.0 then 1  
                                  else 0  
                             end)   
                  end) and    */   
             what_if_ind = 'N' and  
             is_equiv_ind = 'N' AND   
             exists (select 1  
                     from dbo.jms_reports jms  
                     where jms.classification_code like '[A,a]%' and  
                           d.real_port_num = jms.port_num)) tid  
               INNER JOIN (select *  
                           from dbo.v_VAR_position_info  
                           where pos_type <> 'I' and         
                                 1 = (case when pos_type = 'F'   
                                              then (case when last_trade_date >= dateadd(dd, -10, getdate())  
                                                            then 1  
                                                         else 0  
                                                    end)  
                                           else 1  
                                      end)) p  
                 ON p.pos_num = tid.pos_num   
              INNER JOIN dbo.v_VAR_trade_item_info ti      
                 ON tid.trade_num = ti.trade_num and         
                    tid.order_num = ti.order_num and         
                    tid.item_num = ti.item_num         
--where price_status <> 'F'  
where 1 = (case when ti.order_type_code like 'SWAP%'   
                   then case when tid.dist_type <> 'D' then 1  
                             else 0  
                        end  
                else 1 end)      
union             
select distinct   
   i.trade_num,           
   i.order_num,  
   i.item_num,   
   i.trader_init,   
   i.contr_date,   
   i.acct_num,           
   'STORAGE',           
   'N',           
   'Inv'  + (case when p.is_hedge_ind = 'Y' then ' Hedge'   
                  else ' Prim'   
             end),          
   p.booking_company_num,  
   p.group_code,  
   p.profit_center_code,          
   p.real_port_num,  
   i.inv_num,  
   p.pos_num,  
   p.parent_cmdty_code,   
   p.cmdty_code,  
   p.cmdty_short_name,   
   p.mkt_code,           
   p.mkt_short_name,  
   p.mkt_type,  
   p.commkt_key,   
   p.trading_prd,  
   p.pos_type,   
   'P',                         /* tid_p_s_ind */  
   i.inv_qty,                   /* dist_qty */  
   0.0,                         /* alloc_qty */  
   i.inv_qty_uom_code,          /* tid_qty_uom_code */  
   null,                        /* tid_qty_uom_code_conv_to */  
   null,                        /* tid_qty_uom_conv_rate */  
   null,                        /* tid_price_curr_conv_to */  
   null,                        /* tid_price_curr_conv_rate */     
   p.is_equiv_ind,  
   'P',                         /* contract_p_s_ind */  
   p.qty_uom_code,              /* contract_qty_uom_code */  
   p.long_qty - p.short_qty,    /* contract_qty */           
   p.mtm_price_source_code,         
   p.is_hedge_ind,          
   p.trading_prd_desc,          
   p.first_del_date,  
   p.last_del_date,  
   p.last_issue_date,  
   p.last_trade_date,          
   i.creation_date,             /* trade_mod_date */      
   i.creation_date,   
   p.trans_id,   
   p.trading_entity_num,       
   p.last_issue_date,          /* price_risk_date */      
   NULL,                       /* product */      
   p.phy_commkt_curr_code,   
   p.phy_commkt_price_uom_code,  
   p.phy_sec_price_source_code,   
   p.fut_commkt_curr_code,   
   p.fut_commkt_price_uom_code,   
   p.fut_sec_price_source_code,  
   p.price_curr_code,  
   p.price_uom_code,  
   i.creator_init,  
   p.option_type,  
   p.opt_exp_date,  
   p.opt_start_date,  
   p.settlement_type,  
   p.put_call_ind,  
   p.strike_price,  
   p.strike_price_curr_code,  
   p.strike_price_uom_code,  
   i.item_type,  
   i.del_date_to,  
   null,                  /* dist_type */  
   i.formula_ind,  
   p.qty_uom_code,  
   case when p.mtm_price_source_code is not null   
           then p.mtm_price_source_code  
        else (case when p.mkt_type = 'P' then p.phy_sec_price_source_code  
                   else p.fut_sec_price_source_code  
              end)  
   end,  
   i.booking_comp_num,  
   i.open_close_ind,   
   i.inv_type   
from (select *   
      from dbo.v_VAR_position_info   
      where pos_type = 'I') p  
        INNER JOIN dbo.v_VAR_inventory_info i       
           ON i.pos_num = p.pos_num  
GO
GRANT SELECT ON  [dbo].[v_VAR_financial_position] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_financial_position] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_financial_position', NULL, NULL
GO
