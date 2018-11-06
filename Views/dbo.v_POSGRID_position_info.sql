SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_position_info]
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
   real_port_num,                       
   trans_id
)
as
select p.pos_num,
       p.commkt_key,
       case when cg.parent_cmdty_code = 'FOREXGRP' then 'FORWARD' 
            else tp.trading_prd 
       end,                
       port.trading_entity_num,
       cg.parent_cmdty_code,
       p.is_hedge_ind,
       p.is_equiv_ind,
       p.pos_type,
       (case when p.pos_type = 'F' then 'Fut'                        
             when p.pos_type = 'S' then 'Synth'                        
             when p.pos_type = 'P' then 'Phys'                        
             when p.pos_type = 'Q' and option_type = 'S' then 'Swap Form'                        
             when p.pos_type = 'Q' and option_type is null then 'Trade Form'                        
             when p.pos_type = 'M' then 'MTM Form'              
             else p.pos_type                        
        end) + '' + (case when p.is_hedge_ind = 'Y' then ' Hedge' 
                          else ' Prim' 
                     end) + '' + (case when p.is_equiv_ind = 'Y' then ' Equiv' 
                                       else '' 
                                  end) as pos_type_desc, 
       te.booking_comp_num, 
       pt.group_code,
       pt.profit_center_code,                        
       cm1.cmdty_code,
       cm1.mkt_code, 
       cm1.mtm_price_source_code,                         
       case when cg.parent_cmdty_code = 'FOREXGRP' then 'FORWARD' 
            else tp.trading_prd_desc 
       end,                        
       tp.last_issue_date,                        
       tp.last_trade_date, 
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
      p.pos_type not in ('W', 'X', 'O', 'I') and 
      ((p.pos_type = 'F' and 
        tp.last_trade_date >= dateadd(dd, -10, getdate())) OR p.pos_type <> 'F') and 
      not exists (select 1
                  from dbo.POSGRID_excluded_pos_nums e with (nolock) 
                  where p.pos_num = e.pos_num) and 
      p.pos_status not in ('YNN', 'NNN')                                   
GO
GRANT SELECT ON  [dbo].[v_POSGRID_position_info] TO [next_usr]
GO
