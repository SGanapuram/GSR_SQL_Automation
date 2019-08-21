SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchEdplEventRevPK]
(
   @asof_trans_id      bigint,
   @oid                int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.edpl_event
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      ai_est_actual_num,
      alloc_item_num,
      alloc_num,
      app_name,
      asof_trans_id = @asof_trans_id,
      cost_num,
      entity_id,
      event_trans_id,
      event_type,
      inv_num,
      item_num,
      key1,
      key2,
      key3,
      key4,
      key5,
      oid,
      order_num,
      pos_num,
      real_port_num,
      related_event_ids,
      resp_trans_id = null,
      status,
      trade_num,
      trans_id
   from dbo.edpl_event
   where oid = @oid
end
else
begin
   select top 1
      ai_est_actual_num,
      alloc_item_num,
      alloc_num,
      app_name,
      asof_trans_id = @asof_trans_id,
      cost_num,
      entity_id,
      event_trans_id,
      event_type,
      inv_num,
      item_num,
      key1,
      key2,
      key3,
      key4,
      key5,
      oid,
      order_num,
      pos_num,
      real_port_num,
      related_event_ids,
      resp_trans_id,
      status,
      trade_num,
      trans_id
   from dbo.aud_edpl_event
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchEdplEventRevPK] TO [next_usr]
GO
