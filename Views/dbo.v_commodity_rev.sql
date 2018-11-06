SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_commodity_rev]
(
   cmdty_code,
   cmdty_tradeable_ind,
   cmdty_type,
   cmdty_status,
   cmdty_short_name,
   cmdty_full_name,
   country_code,
   cmdty_loc_desc,
   prim_curr_code,
   prim_curr_conv_rate,
   prim_uom_code,
   sec_uom_code,
   cmdty_category_code,
   grade,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   cmdty_code,
   cmdty_tradeable_ind,
   cmdty_type,
   cmdty_status,
   cmdty_short_name,
   cmdty_full_name,
   country_code,
   cmdty_loc_desc,
   prim_curr_code,
   prim_curr_conv_rate,
   prim_uom_code,
   sec_uom_code,
   cmdty_category_code,
   grade,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_commodity
GO
GRANT SELECT ON  [dbo].[v_commodity_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_commodity_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_commodity_rev', NULL, NULL
GO
