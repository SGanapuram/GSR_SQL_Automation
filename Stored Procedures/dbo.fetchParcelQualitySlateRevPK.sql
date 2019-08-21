SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchParcelQualitySlateRevPK]
(
   @asof_trans_id      bigint,
   @oid                int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.parcel_quality_slate
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      oid,
      parcel_id,
      quality_slate_id,
      resp_trans_id = null,
      trans_id
   from dbo.parcel_quality_slate
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      oid,
      parcel_id,
      quality_slate_id,
      resp_trans_id,
      trans_id
   from dbo.aud_parcel_quality_slate
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchParcelQualitySlateRevPK] TO [next_usr]
GO
