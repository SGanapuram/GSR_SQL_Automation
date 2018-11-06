SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_icts_message_rev]
(
   oid,
   msg_type,      
   msg_description,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   msg_type,      
   msg_description,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_icts_message
GO
GRANT SELECT ON  [dbo].[v_icts_message_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_icts_message_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_icts_message_rev', NULL, NULL
GO
