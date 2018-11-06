SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_pl_history_rev]
(
   pl_record_key,
   pl_owner_code,
   pl_asof_date,
   real_port_num,
   pl_owner_sub_code,
   pl_record_owner_key,
   pl_primary_owner_key1,
   pl_primary_owner_key2,
   pl_primary_owner_key3,
   pl_primary_owner_key4,
   pl_secondary_owner_key1,
   pl_secondary_owner_key2,
   pl_secondary_owner_key3,
   pl_type,
   pl_category_type,
   pl_realization_date,
   pl_cost_status_code,
   pl_cost_prin_addl_ind,
   pl_mkt_price,
   pl_amt,
   currency_fx_rate,
   pl_record_qty,
   pl_record_qty_uom_code,
   pos_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   pl_record_key,
   pl_owner_code,
   pl_asof_date,
   real_port_num,
   pl_owner_sub_code,
   pl_record_owner_key,
   pl_primary_owner_key1,
   pl_primary_owner_key2,
   pl_primary_owner_key3,
   pl_primary_owner_key4,
   pl_secondary_owner_key1,
   pl_secondary_owner_key2,
   pl_secondary_owner_key3,
   pl_type,
   pl_category_type,
   pl_realization_date,
   pl_cost_status_code,
   pl_cost_prin_addl_ind,
   pl_mkt_price,
   pl_amt,
   currency_fx_rate,
   pl_record_qty,
   pl_record_qty_uom_code,
   pos_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_pl_history
GO
GRANT SELECT ON  [dbo].[v_pl_history_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_pl_history_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_pl_history_rev', NULL, NULL
GO
