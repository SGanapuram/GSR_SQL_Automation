SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchRepriceEventDetailRevPK]
(
   @asof_trans_id                 int,
   @reprice_event_detail_num      smallint,
   @reprice_event_oid             int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.reprice_event_detail
where reprice_event_oid = @reprice_event_oid and
      reprice_event_detail_num = @reprice_event_detail_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      entity_id,
      key1,
      key2,
      key3,
      key4,
      reprice_event_detail_num,
      reprice_event_oid,
      resp_trans_id = null,
      status,
      trans_id
   from dbo.reprice_event_detail
   where reprice_event_oid = @reprice_event_oid and
         reprice_event_detail_num = @reprice_event_detail_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      entity_id,
      key1,
      key2,
      key3,
      key4,
      reprice_event_detail_num,
      reprice_event_oid,
      resp_trans_id,
      status,
      trans_id
   from dbo.aud_reprice_event_detail
   where reprice_event_oid = @reprice_event_oid and
         reprice_event_detail_num = @reprice_event_detail_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchRepriceEventDetailRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchRepriceEventDetailRevPK', NULL, NULL
GO
