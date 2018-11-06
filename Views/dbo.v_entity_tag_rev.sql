SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_entity_tag_rev]
(
   entity_tag_key,
   entity_tag_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   key6,
   key7,
   key8,
   target_key1,
   target_key2,
   target_key3,
   target_key4,
   target_key5,
   target_key6,
   target_key7,
   target_key8,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   entity_tag_key,
   entity_tag_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   key6,
   key7,
   key8,
   target_key1,
   target_key2,
   target_key3,
   target_key4,
   target_key5,
   target_key6,
   target_key7,
   target_key8,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_entity_tag
GO
GRANT SELECT ON  [dbo].[v_entity_tag_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_entity_tag_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_entity_tag_rev', NULL, NULL
GO
