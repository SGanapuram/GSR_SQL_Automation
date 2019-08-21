SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_vessel_dist_rev]
(
   oid,
   commkt_key,
   trading_prd,
   key1,
   key2,
   key3,
   p_s_ind,
   dist_type,
   dist_status,
   dist_qty,
   alloc_qty,
   qty_uom_code,
   avg_price,
   price_uom_code,
   price_curr_code,
   real_port_num,
   pos_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   commkt_key,
   trading_prd,
   key1,
   key2,
   key3,
   p_s_ind,
   dist_type,
   dist_status,
   dist_qty,
   alloc_qty,
   qty_uom_code,
   avg_price,
   price_uom_code,
   price_curr_code,
   real_port_num,
   pos_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_vessel_dist
GO
GRANT SELECT ON  [dbo].[v_vessel_dist_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_vessel_dist_rev] TO [next_usr]
GO
