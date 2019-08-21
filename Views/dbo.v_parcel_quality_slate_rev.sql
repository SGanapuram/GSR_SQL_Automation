SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_parcel_quality_slate_rev]
(
   oid,
   parcel_id,
   quality_slate_id,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   parcel_id,
   quality_slate_id,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_parcel_quality_slate
GO
GRANT SELECT ON  [dbo].[v_parcel_quality_slate_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_parcel_quality_slate_rev] TO [next_usr]
GO
