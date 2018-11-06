SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchEntityTagRevPK]
(
   @asof_trans_id       int,
   @entity_tag_key      int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.entity_tag
where entity_tag_key = @entity_tag_key
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      entity_tag_id,
      entity_tag_key,
      key1,
      key2,
      key3,
      key4,
      key5,
      key6,
      key7,
      key8,
      resp_trans_id = null,
      target_key1,
      target_key2,
      target_key3,
      target_key4,
      target_key5,
      target_key6,
      target_key7,
      target_key8,
      trans_id
   from dbo.entity_tag
   where entity_tag_key = @entity_tag_key
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      entity_tag_id,
      entity_tag_key,
      key1,
      key2,
      key3,
      key4,
      key5,
      key6,
      key7,
      key8,
      resp_trans_id,
      target_key1,
      target_key2,
      target_key3,
      target_key4,
      target_key5,
      target_key6,
      target_key7,
      target_key8,
      trans_id
   from dbo.aud_entity_tag
   where entity_tag_key = @entity_tag_key and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchEntityTagRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchEntityTagRevPK', NULL, NULL
GO
