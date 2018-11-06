SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_voucher_cost_rev]
(
   voucher_num,
   cost_num,
   prov_price,
   prov_price_curr_code,
   prov_qty,
   prov_qty_uom_code,
   prov_amt,
   line_num,
   voucher_cost_status,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   voucher_num,
   cost_num,
   prov_price,
   prov_price_curr_code,
   prov_qty,
   prov_qty_uom_code,
   prov_amt,
   line_num,
   voucher_cost_status,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_voucher_cost
GO
GRANT SELECT ON  [dbo].[v_voucher_cost_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_voucher_cost_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_voucher_cost_rev', NULL, NULL
GO
