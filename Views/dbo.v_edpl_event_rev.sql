SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_edpl_event_rev]
(
   oid,
   status,
   event_trans_id,
   app_name,
   entity_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   trade_num,
   order_num,
   item_num,
   cost_num,
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   inv_num,
   real_port_num,
   related_event_ids,
   pos_num,
   event_type,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   status,
   event_trans_id,
   app_name,
   entity_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   trade_num,
   order_num,
   item_num,
   cost_num,
   alloc_num,
   alloc_item_num,
   ai_est_actual_num,
   inv_num,
   real_port_num,
   related_event_ids,
   pos_num,
   event_type,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_edpl_event
GO
GRANT SELECT ON  [dbo].[v_edpl_event_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_edpl_event_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_edpl_event_rev', NULL, NULL
GO
