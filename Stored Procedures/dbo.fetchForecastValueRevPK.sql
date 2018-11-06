SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchForecastValueRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.forecast_value
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_num,
      asof_trans_id = @asof_trans_id,
      booking_comp_num,
      commkt_key,
      del_date_from,
      del_date_to,
      del_loc_code,
      forecast_pos_num,
      forecast_qty,
      forecast_qty_uom_code,
      mot_type_code,
      oid,
      p_s_ind,
      phy_pos_num,
      real_port_num,
      resp_trans_id = null,
      trading_prd,
      trans_id
   from dbo.forecast_value
   where oid = @oid
end
else
begin
   select top 1
      acct_num,
      asof_trans_id = @asof_trans_id,
      booking_comp_num,
      commkt_key,
      del_date_from,
      del_date_to,
      del_loc_code,
      forecast_pos_num,
      forecast_qty,
      forecast_qty_uom_code,
      mot_type_code,
      oid,
      p_s_ind,
      phy_pos_num,
      real_port_num,
      resp_trans_id,
      trading_prd,
      trans_id
   from dbo.aud_forecast_value
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchForecastValueRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchForecastValueRevPK', NULL, NULL
GO
