SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[jms_legal_entity]
(
   legal_entity_code,
   legal_entity_name,
   trans_id
)
as
select
   tag_option,
   tag_option_desc,
   trans_id
from dbo.entity_tag_option eto with (nolock)
where exists (select 1
              from dbo.entity_tag_definition etd with (nolock)
              where etd.entity_id = (select oid 
                                     from dbo.icts_entity_name with (nolock) 
                                     where entity_name = 'Portfolio') and
                    etd.entity_tag_name = 'LEGALENT' and
                    eto.entity_tag_id = etd.oid)
GO
GRANT SELECT ON  [dbo].[jms_legal_entity] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[jms_legal_entity] TO [next_usr]
GO
