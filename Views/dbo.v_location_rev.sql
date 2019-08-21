SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_location_rev]
(
   loc_code,
   loc_name,
   office_loc_ind,
   del_loc_ind,
   inv_loc_ind,
   loc_num,
   loc_status,
   latitude,
   longitude,
   warehouse_agp_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   loc_code,
   loc_name,
   office_loc_ind,
   del_loc_ind,
   inv_loc_ind,
   loc_num,
   loc_status,
   latitude,
   longitude,
   warehouse_agp_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_location
GO
GRANT SELECT ON  [dbo].[v_location_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_location_rev] TO [next_usr]
GO
