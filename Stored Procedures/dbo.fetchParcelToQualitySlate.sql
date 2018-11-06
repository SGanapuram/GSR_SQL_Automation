SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchParcelToQualitySlate]
(
   @asof_trans_id      int,
   @parcel_id          int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          oid,
          parcel_id,
          quality_slate_id,
          resp_trans_id = NULL,
          trans_id
   from dbo.parcel_quality_slate
   where parcel_id = @parcel_id and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          oid,
          parcel_id,
          quality_slate_id,
          resp_trans_id,
          trans_id
   from dbo.aud_parcel_quality_slate
   where parcel_id = @parcel_id and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchParcelToQualitySlate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchParcelToQualitySlate', NULL, NULL
GO
