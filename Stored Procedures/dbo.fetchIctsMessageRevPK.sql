SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchIctsMessageRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.icts_message
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      msg_description,
      msg_type,
      oid,
      resp_trans_id = null,
      trans_id
   from dbo.icts_message
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      msg_description,
      msg_type,
      oid,
      resp_trans_id,
      trans_id
   from dbo.aud_icts_message
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchIctsMessageRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchIctsMessageRevPK', NULL, NULL
GO
