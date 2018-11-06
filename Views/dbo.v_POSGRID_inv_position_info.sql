SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_inv_position_info]
(
   pos_num,
   commkt_key,
   trading_prd, 
   trading_entity_num,
   parent_cmdty_code,
   is_hedge_ind,
   is_equiv_ind,
   pos_type,
   pos_type_desc, 
   booking_comp_num, 
   risk_group_code,
   profit_center_code,                        
   cmdty_code,
   mkt_code, 
   mtm_price_source_code,                         
   trading_prd_desc, 
   last_issue_date,                        
   last_trade_date, 
   long_qty,
   short_qty,                       
   sec_long_qty,
   sec_short_qty,
   qty_uom_code,
   sec_pos_uom_code, 
   real_port_num,                     
   trans_id
)
as
select p.pos_num,
       p.commkt_key,
       tp.trading_prd, 
       port.trading_entity_num,
       cg.parent_cmdty_code,
       p.is_hedge_ind,
       p.is_equiv_ind,
       p.pos_type,
       'Inv' + (case when p.is_hedge_ind = 'Y' then ' Hedge' 
                     else ' Prim' 
                end),                    
       te.booking_comp_num, 
       pt.group_code,
       pt.profit_center_code,                        
       cm1.cmdty_code,
       cm1.mkt_code, 
       cm1.mtm_price_source_code,                         
       tp.trading_prd_desc,                        
       tp.last_issue_date,                        
       tp.last_trade_date, 
       p.long_qty,
       p.short_qty,                       
       p.sec_long_qty,
       p.sec_short_qty,
       p.qty_uom_code, 
       p.sec_pos_uom_code,  
       p.real_port_num,                   
       p.trans_id
from dbo.position p with (nolock)                      
        LEFT OUTER JOIN dbo.portfolio as port with (nolock) 
           ON p.real_port_num = port.port_num                    
        LEFT OUTER JOIN dbo.commodity_group as cg with (nolock)
           ON p.cmdty_code = cg.cmdty_code and 
              cmdty_group_type_code = 'POSITION'                        
        LEFT OUTER JOIN dbo.trading_period as tp with (nolock) 
           ON p.commkt_key = tp.commkt_key and 
              p.trading_prd = tp.trading_prd                           
        LEFT OUTER JOIN dbo.jms_reports as pt with (nolock)  
           ON pt.port_num = p.real_port_num                         
        LEFT OUTER JOIN (select convert(int, tag_value) as booking_comp_num, 
                                port_num 
                         from dbo.portfolio_tag with (nolock) 
                         where tag_name = 'BOOKCOMP') as te 
           ON te.port_num = p.real_port_num,
     dbo.commodity_market cm1 with (nolock)
where p.commkt_key = cm1.commkt_key and 
      p.pos_type = 'I' and 
      (round(isnull(long_qty, 0.0) - isnull(short_qty, 0.0), 2) ) <> 0 and 
      p.pos_status not in ('YNN', 'NNN')                   
GO
GRANT SELECT ON  [dbo].[v_POSGRID_inv_position_info] TO [next_usr]
GO
