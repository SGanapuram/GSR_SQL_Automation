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
   strategy_code          
)
as
select t.port_num,
       p.port_short_name,
       TRADER,
       [GROUP],
       PRFTCNTR,
       DESK,
       LOCATION,
       LEGALENT,
       DIVISION,
       DEPT,
       CLASS,
       STRATEGY 
from (select port_num,
       TRADER,
       [GROUP],
       PRFTCNTR,
       DESK,
       LOCATION,
       LEGALENT,
       DIVISION,
       DEPT,
       CLASS,
       STRATEGY 
from (select cast(key1 as int) as port_num,
             etd.entity_tag_name, 
             et.target_key1
      from dbo.entity_tag et with (nolock)
              INNER JOIN dbo.entity_tag_definition etd with (nolock)
                 ON et.entity_tag_id = etd.oid
      where entity_id = (select oid 
                         from dbo.icts_entity_name ent with (nolock)
                         where entity_name = 'Portfolio')) as s
       PIVOT (max(target_key1)
              for entity_tag_name in (TRADER,[GROUP],PRFTCNTR,DESK,LOCATION,
                                      LEGALENT,DIVISION,DEPT,CLASS,STRATEGY)) pvt) t
         JOIN dbo.portfolio p
            ON t.port_num = p.port_num
GO
GRANT SELECT ON  [dbo].[jms_reports] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_reports] TO [next_usr]
GO
