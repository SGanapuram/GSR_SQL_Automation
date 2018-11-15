SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_VAR_position_info]     
(  
   pos_num,  
   real_port_num,  
   pos_type,  
   is_equiv_ind,  
   is_hedge_ind,          
   cmdty_code,  
   cmdty_short_name,   
   mkt_code,           
   mkt_short_name,  
   mkt_type,  
   mtm_price_source_code,           
   commkt_key,   
   parent_cmdty_code,  
   trading_prd,  
   trading_prd_desc,  
   first_del_date,  
   last_del_date,  
   last_issue_date,  
   last_trade_date,  
   trading_entity_num,  
   group_code,  
   profit_center_code,   
   long_qty,  
   short_qty,  
   qty_uom_code,         
   sec_long_qty,  
   sec_short_qty,        
   sec_pos_uom_code,  
   booking_company_num,   
   option_type,  
   trans_id,  
   phy_commkt_curr_code,   
   phy_commkt_price_uom_code,  
   phy_sec_price_source_code,   
   fut_commkt_curr_code,   
   fut_commkt_price_uom_code,   
   fut_sec_price_source_code,  
   price_curr_code,  
   price_uom_code,  
   opt_exp_date,  
   opt_start_date,  
   settlement_type,  
   put_call_ind,  
   strike_price,  
   strike_price_curr_code,  
   strike_price_uom_code  
)  
as  
select  
   p.pos_num,  
   p.real_port_num,  
   p.pos_type,  
   p.is_equiv_ind,  
   p.is_hedge_ind,          
   cm.cmdty_code,  
   cm.cmdty_short_name,   
   cm.mkt_code,           
   cm.mkt_short_name,  
   cm.mkt_type,  
   cm.mtm_price_source_code,           
   p.commkt_key,   
   cg.parent_cmdty_code,  
   case when cg.parent_cmdty_code = 'FOREXGRP' then 'FORWARD'   
        else tp.trading_prd   
   end,  
   case when cg.parent_cmdty_code = 'FOREXGRP' then 'FORWARD'   
        else tp.trading_prd_desc   
   end,  
   tp.first_del_date,  
   tp.last_del_date,  
   tp.last_issue_date,  
   tp.last_trade_date,  
   port.trading_entity_num,  
   pt.group_code,  
   pt.profit_center_code,          
   p.long_qty,  
   p.short_qty,  
   p.qty_uom_code,         
   p.sec_long_qty,  
   p.sec_short_qty,        
   p.sec_pos_uom_code,   
   te.booking_company_num,  
   p.option_type,  
   p.trans_id,  
   cm.phy_commkt_curr_code,   
   cm.phy_commkt_price_uom_code,  
   cm.phy_sec_price_source_code,   
   cm.fut_commkt_curr_code,   
   cm.fut_commkt_price_uom_code,   
   cm.fut_sec_price_source_code,  
   p.price_curr_code,  
   p.price_uom_code,  
   p.opt_exp_date,  
   p.opt_start_date,  
   p.settlement_type,  
   p.put_call_ind,  
   p.strike_price,  
   p.strike_price_curr_code,  
   p.strike_price_uom_code  
from dbo.position p  
        LEFT JOIN dbo.v_VAR_commkt_info cm   
           ON p.commkt_key = cm.commkt_key          
        LEFT OUTER JOIN dbo.portfolio port WITH (NOLOCK)  
           ON p.real_port_num = port.port_num      
        LEFT OUTER JOIN (select parent_cmdty_code,  
                                cmdty_code  
                         from dbo.commodity_group WITH (NOLOCK)  
                         where cmdty_group_type_code = 'POSITION') cg  
           ON cm.cmdty_code = cg.cmdty_code                       
        LEFT OUTER JOIN dbo.trading_period tp WITH (NOLOCK)  
           ON p.commkt_key = tp.commkt_key and   
              p.trading_prd = tp.trading_prd             
        LEFT OUTER JOIN dbo.jms_reports pt   
           ON pt.port_num = p.real_port_num           
        LEFT OUTER JOIN dbo.v_VAR_booking_company_info te   
           ON te.port_num = p.real_port_num  
GO
GRANT SELECT ON  [dbo].[v_VAR_position_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_VAR_position_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_VAR_position_info', NULL, NULL
GO
