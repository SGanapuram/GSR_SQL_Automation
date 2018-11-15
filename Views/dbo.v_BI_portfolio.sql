SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_BI_portfolio]          
(          
   parent_port_num,           
   port_num,            
   port_type,           
   port_short_name,           
   port_full_name,           
   desired_pl_curr_code,          
   trading_entity_num,           
   port_locked,           
   trans_id,           
   trader_init,           
   group_code,           
   profit_center_code,           
   desk_code,           
   location_code,           
   legal_entity_code,           
   division_code,           
   department_code,           
   classification_code,           
   strategy_code,          
   booking_company,         
   Trader1,      
   trader_init2,      
   Trader2,      
   trader_init3,      
   Trader3,      
   trader_init4,      
   Trader4,      
   trader_init5,      
   Trader5,      
   profit_center_desc,  
   group_desc,  
   desk_desc,  
   location_desc,  
   legal_entity_desc,  
   division_desc,  
   department_desc,  
   booking_company_desc,  
   risk_function_code,  
   risk_function_desc  
)          
as          
select 
   parent_port_num, 
   p.port_num,  
   p.port_type, 
   p.port_short_name, 
   p.port_full_name, 
   p.desired_pl_curr_code,
   p.trading_entity_num, 
   p.port_locked,            
   p.trans_id, 
   j.trader_init, 
   j.group_code, 
   j.profit_center_code, 
   j.desk_code, 
   j.location_code, 
   j.legal_entity_code, 
   j.division_code, 
   j.department_code,            
   j.classification_code, 
   j.strategy_code,
   pt1.tag_value 'booking_company' ,      
   trd1.user_first_name + ' '  + trd1.user_last_name 'Trader1',      
   pt2.tag_value 'trader_init2',
   trd2.user_first_name + ' '  + trd2.user_last_name 'Trader2',      
   pt3.tag_value 'trader_init3',
   trd3.user_first_name + ' '  + trd3.user_last_name 'Trader3',      
   pt4.tag_value 'trader_init4', 
   trd4.user_first_name + ' '  + trd4.user_last_name 'Trader4',      
   pt5.tag_value 'trader_init5',
   trd5.user_first_name + ' '  + trd5.user_last_name 'Trader5',      
   eto.tag_option_desc 'profit_center_desc'   ,  
   grp.tag_option_desc 'group_desc',  
   dsk.tag_option_desc 'desk_desc',
   loc.tag_option_desc 'location_desc',
   le.tag_option_desc 'legal_entity_desc',
   div.tag_option_desc 'division_desc',  
   dep.tag_option_desc 'department_desc',
   bcomp.acct_short_name 'booking_company_desc',
   rsk.tag_value 'risk_function_code',
   rskdsc.tag_option_desc 'risk_function_desc'  
from portfolio_group pg, 
     portfolio p            
        LEFT OUTER JOIN jms_reports j 
           ON j.port_num = p.port_num        
        LEFT OUTER JOIN icts_user trd1 
           ON trd1.user_init = j.trader_init      
        LEFT OUTER JOIN entity_tag_option eto 
           ON eto.entity_tag_id = dbo.udf_portfolio_tag_id('PRFTCNTR') and 
              eto.tag_option = j.profit_center_code      
        LEFT OUTER JOIN entity_tag_option grp 
           ON grp.entity_tag_id = dbo.udf_portfolio_tag_id('GROUP') and 
              grp.tag_option = j.group_code  
        LEFT OUTER JOIN entity_tag_option dsk 
           ON dsk.entity_tag_id = dbo.udf_portfolio_tag_id('DESK') and 
              dsk.tag_option = j.desk_code  
        LEFT OUTER JOIN entity_tag_option loc 
           ON loc.entity_tag_id = dbo.udf_portfolio_tag_id('LOCATION') and 
              loc.tag_option = j.location_code  
        LEFT OUTER JOIN entity_tag_option le 
           ON le.entity_tag_id = dbo.udf_portfolio_tag_id('LEGALENT') and 
              le.tag_option = j.legal_entity_code  
        LEFT OUTER JOIN entity_tag_option div 
           ON div.entity_tag_id = dbo.udf_portfolio_tag_id('DIVISION') and 
              div.tag_option = j.division_code  
        LEFT OUTER JOIN entity_tag_option dep 
           ON dep.entity_tag_id = dbo.udf_portfolio_tag_id('DEPT') and 
              dep.tag_option = j.department_code  
        LEFT OUTER JOIN portfolio_tag pt1 
           on pt1.port_num = p.port_num and 
              pt1.tag_name = 'BOOKCOMP'          
        LEFT OUTER JOIN account bcomp 
           ON acct_num = pt1.tag_value  
        LEFT OUTER JOIN portfolio_tag rsk 
           on rsk.port_num = p.port_num and 
              rsk.tag_name = 'RSKFNCTN'          
        LEFT OUTER JOIN entity_tag_option rskdsc 
           ON rskdsc.entity_tag_id = dbo.udf_portfolio_tag_id('RSKFNCTN') and 
              rskdsc.tag_option = rsk.tag_value  
        LEFT OUTER JOIN portfolio_tag pt2 
           on pt2.port_num = p.port_num and 
              pt2.tag_name = 'TRADER2'          
        LEFT OUTER JOIN portfolio_tag pt3 
           on pt3.port_num = p.port_num and 
              pt3.tag_name = 'TRADER3'          
        LEFT OUTER JOIN portfolio_tag pt4 
           on pt4.port_num = p.port_num and 
              pt4.tag_name = 'TRADER4'          
        LEFT OUTER JOIN portfolio_tag pt5 
           on pt5.port_num = p.port_num and 
              pt5.tag_name = 'TRADER5'          
        LEFT OUTER JOIN icts_user trd2 
           ON trd2.user_init = pt2.tag_value       
        LEFT OUTER JOIN icts_user trd3 
           ON trd3.user_init = pt3.tag_value       
        LEFT OUTER JOIN icts_user trd4 
           ON trd4.user_init = pt4.tag_value       
        LEFT OUTER JOIN icts_user trd5 
           ON trd5.user_init = pt5.tag_value       
where p.port_num = pg.port_num and 
      port_type not in ('P', 'G') and 
      is_link_ind = 'N'        
GO
GRANT SELECT ON  [dbo].[v_BI_portfolio] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_BI_portfolio', NULL, NULL
GO
