SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_icts_message_detail_rev]
(
   oid,
   message_id,
   icts_entity_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   key6,
   op_trans_id,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   message_id,
   icts_entity_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   key6,
   op_trans_id,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_icts_message_detail
GO
GRANT SELECT ON  [dbo].[v_icts_message_detail_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_icts_message_detail_rev] TO [next_usr]
GO
