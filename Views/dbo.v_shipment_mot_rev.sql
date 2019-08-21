SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_shipment_mot_rev]
(
   shipment_num,
   mot_code,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   shipment_num,
   mot_code,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_shipment_mot
GO
GRANT SELECT ON  [dbo].[v_shipment_mot_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_shipment_mot_rev] TO [next_usr]
GO
