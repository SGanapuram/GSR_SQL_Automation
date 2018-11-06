SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_eipp_task_rev]
(
   oid,
   creation_date,
   eipp_entity_name,
   key1,
   key2,
   key3,
   key4,
   eipp_status,
   eipp_substatus,
   task_name_oid,
   task_xml,
   op_trans_id,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   substatus_xml
)
as
select
   oid,
   creation_date,
   eipp_entity_name,
   key1,
   key2,
   key3,
   key4,
   eipp_status,
   eipp_substatus,
   task_name_oid,
   task_xml,
   op_trans_id,
   trans_id,
   trans_id,
   resp_trans_id,
   substatus_xml
from dbo.aud_eipp_task
GO
GRANT SELECT ON  [dbo].[v_eipp_task_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_eipp_task_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_eipp_task_rev', NULL, NULL
GO
