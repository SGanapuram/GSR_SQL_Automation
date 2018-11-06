SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchVesselDistRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.vessel_dist
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      alloc_qty,
      asof_trans_id = @asof_trans_id,
      avg_price,
      commkt_key,
      dist_qty,
      dist_status,
      dist_type,
      key1,
      key2,
      key3,
      oid,
      p_s_ind,
      pos_num,
      price_curr_code,
      price_uom_code,
      qty_uom_code,
      real_port_num,
      resp_trans_id = null,
      trading_prd,
      trans_id
   from dbo.vessel_dist
   where oid = @oid
end
else
begin
   select top 1
      alloc_qty,
      asof_trans_id = @asof_trans_id,
      avg_price,
      commkt_key,
      dist_qty,
      dist_status,
      dist_type,
      key1,
      key2,
      key3,
      oid,
      p_s_ind,
      pos_num,
      price_curr_code,
      price_uom_code,
      qty_uom_code,
      real_port_num,
      resp_trans_id,
      trading_prd,
      trans_id
   from dbo.aud_vessel_dist
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchVesselDistRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchVesselDistRevPK', NULL, NULL
GO
