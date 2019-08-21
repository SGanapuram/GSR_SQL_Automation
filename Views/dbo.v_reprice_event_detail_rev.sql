SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_reprice_event_detail_rev]
(
   reprice_event_oid,
   reprice_event_detail_num,
   entity_id,
   key1,
   key2,
   key3,
   key4,
   status,
   trans_id,
   resp_trans_id 
)
as
select
   reprice_event_oid,
   reprice_event_detail_num,
   entity_id,
   key1,
   key2,
   key3,
   key4,
   status,
   trans_id,
   resp_trans_id 
from aud_reprice_event_detail
GO
GRANT SELECT ON  [dbo].[v_reprice_event_detail_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_reprice_event_detail_rev] TO [next_usr]
GO
