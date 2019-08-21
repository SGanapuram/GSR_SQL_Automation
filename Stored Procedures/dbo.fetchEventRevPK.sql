SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchEventRevPK]
(
   @asof_trans_id      bigint,
   @event_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.event
where event_num = @event_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      event_asof_date,
      event_code,
      event_controller,
      event_description,
      event_num,
      event_owner,
      event_owner_key1,
      event_owner_key2,
      event_time,
      resp_trans_id = null,
      trans_id
   from dbo.event
   where event_num = @event_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      event_asof_date,
      event_code,
      event_controller,
      event_description,
      event_num,
      event_owner,
      event_owner_key1,
      event_owner_key2,
      event_time,
      resp_trans_id,
      trans_id
   from dbo.aud_event
   where event_num = @event_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchEventRevPK] TO [next_usr]
GO
