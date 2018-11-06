SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_forecast_value_rev]
(
   oid,
   acct_num,
   booking_comp_num,
   commkt_key,
   del_date_from,
   del_date_to,
   del_loc_code,
   forecast_qty,
   forecast_qty_uom_code,
   mot_type_code,
   p_s_ind,
   forecast_pos_num,
   phy_pos_num,
   real_port_num,
   trading_prd,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   acct_num,
   booking_comp_num,
   commkt_key,
   del_date_from,
   del_date_to,
   del_loc_code,
   forecast_qty,
   forecast_qty_uom_code,
   mot_type_code,
   p_s_ind,
   forecast_pos_num,
   phy_pos_num,
   real_port_num,
   trading_prd,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_forecast_value
GO
GRANT SELECT ON  [dbo].[v_forecast_value_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_forecast_value_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_forecast_value_rev', NULL, NULL
GO
