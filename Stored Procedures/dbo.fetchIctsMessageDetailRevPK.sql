SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchIctsMessageDetailRevPK]
(
   @asof_trans_id      bigint,
   @oid                int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.icts_message_detail
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      icts_entity_id,
      key1,
      key2,
      key3,
      key4,
      key5,
      key6,
      message_id,
      oid,
      op_trans_id,
      resp_trans_id = null,
      trans_id
   from dbo.icts_message_detail
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      icts_entity_id,
      key1,
      key2,
      key3,
      key4,
      key5,
      key6,
      message_id,
      oid,
      op_trans_id,
      resp_trans_id,
      trans_id
   from dbo.aud_icts_message_detail
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchIctsMessageDetailRevPK] TO [next_usr]
GO
