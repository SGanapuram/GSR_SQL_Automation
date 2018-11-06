SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_event_rev]
(
   event_num,
   event_time,
   event_owner,
   event_code,
   event_asof_date,
   event_owner_key1,
   event_owner_key2,
   event_description,
   event_controller,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   event_num,
   event_time,
   event_owner,
   event_code,
   event_asof_date,
   event_owner_key1,
   event_owner_key2,
   event_description,
   event_controller,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_event
GO
GRANT SELECT ON  [dbo].[v_event_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_event_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_event_rev', NULL, NULL
GO
