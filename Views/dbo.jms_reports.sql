SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_reports]
(
   port_num,
   port_short_name,  
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
   trans_id
)
as
select distinct porttag.port_num,
       (select port_short_name
        from dbo.portfolio p
        where p.port_num = porttag.port_num),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'TRADER'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'GROUP'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'PRFTCNTR'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'DESK'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'LOCATION'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'LEGALENT'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'DIVISION'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'DEPT'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'CLASS'),
       (select tag_value
        from dbo.portfolio_tag porttag1
        where porttag.port_num = porttag1.port_num and
              porttag1.tag_name = 'STRATEGY'),
       porttag.trans_id
from dbo.portfolio_tag porttag
where porttag.tag_name = 'JMSRPT'
GO
GRANT SELECT ON  [dbo].[jms_reports] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_reports] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'jms_reports', NULL, NULL
GO
