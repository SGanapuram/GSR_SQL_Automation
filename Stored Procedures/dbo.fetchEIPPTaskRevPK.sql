SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchEIPPTaskRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.eipp_task
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      creation_date,
      eipp_entity_name,
      eipp_status,
      eipp_substatus,
      key1,
      key2,
      key3,
      key4,
      oid,
      op_trans_id,
      resp_trans_id = null,
      substatus_xml,
      task_name_oid,
      task_xml,
      trans_id
   from dbo.eipp_task
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      creation_date,
      eipp_entity_name,
      eipp_status,
      eipp_substatus,
      key1,
      key2,
      key3,
      key4,
      oid,
      op_trans_id,
      resp_trans_id,
      substatus_xml,
      task_name_oid,
      task_xml,
      trans_id
   from dbo.aud_eipp_task
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchEIPPTaskRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchEIPPTaskRevPK', NULL, NULL
GO
