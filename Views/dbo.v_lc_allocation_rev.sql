SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_lc_allocation_rev]
(
   lc_num,
   lc_alloc_num,
   cmdty_code,
   lc_alloc_min_qty,
   lc_alloc_max_qty,
   lc_alloc_qty_uom_code,
   lc_alloc_qty_tol_pcnt,
   lc_alloc_qty_tol_oper,
   lc_alloc_min_amt,
   lc_alloc_max_amt,
   lc_alloc_amt_curr_code,
   lc_alloc_amt_tol_pcnt,
   lc_alloc_amt_tol_oper,
   lc_alloc_amt_cap,
   lc_alloc_base_price,
   lc_alloc_base_price_uom_code,
   lc_alloc_base_price_curr_code,
   lc_alloc_formula_num,
   lc_alloc_start_date,
   lc_alloc_end_date,
   lc_alloc_partial_ship_ind,
   lc_alloc_last_bl_date,
   lc_alloc_trans_ship_ind,
   lc_alloc_amt_left,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   lc_num,
   lc_alloc_num,
   cmdty_code,
   lc_alloc_min_qty,
   lc_alloc_max_qty,
   lc_alloc_qty_uom_code,
   lc_alloc_qty_tol_pcnt,
   lc_alloc_qty_tol_oper,
   lc_alloc_min_amt,
   lc_alloc_max_amt,
   lc_alloc_amt_curr_code,
   lc_alloc_amt_tol_pcnt,
   lc_alloc_amt_tol_oper,
   lc_alloc_amt_cap,
   lc_alloc_base_price,
   lc_alloc_base_price_uom_code,
   lc_alloc_base_price_curr_code,
   lc_alloc_formula_num,
   lc_alloc_start_date,
   lc_alloc_end_date,
   lc_alloc_partial_ship_ind,
   lc_alloc_last_bl_date,
   lc_alloc_trans_ship_ind,
   lc_alloc_amt_left,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_lc_allocation
GO
GRANT SELECT ON  [dbo].[v_lc_allocation_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_lc_allocation_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_lc_allocation_rev', NULL, NULL
GO
