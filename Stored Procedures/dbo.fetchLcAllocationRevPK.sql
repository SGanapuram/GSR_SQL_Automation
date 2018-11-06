SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchLcAllocationRevPK]
(
   @asof_trans_id      int,
   @lc_alloc_num       tinyint,
   @lc_num             int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.lc_allocation
where lc_num = @lc_num and
      lc_alloc_num = @lc_alloc_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cmdty_code,
      lc_alloc_amt_cap,
      lc_alloc_amt_curr_code,
      lc_alloc_amt_left,
      lc_alloc_amt_tol_oper,
      lc_alloc_amt_tol_pcnt,
      lc_alloc_base_price,
      lc_alloc_base_price_curr_code,
      lc_alloc_base_price_uom_code,
      lc_alloc_end_date,
      lc_alloc_formula_num,
      lc_alloc_last_bl_date,
      lc_alloc_max_amt,
      lc_alloc_max_qty,
      lc_alloc_min_amt,
      lc_alloc_min_qty,
      lc_alloc_num,
      lc_alloc_partial_ship_ind,
      lc_alloc_qty_tol_oper,
      lc_alloc_qty_tol_pcnt,
      lc_alloc_qty_uom_code,
      lc_alloc_start_date,
      lc_alloc_trans_ship_ind,
      lc_num,
      resp_trans_id = null,
      trans_id
   from dbo.lc_allocation
   where lc_num = @lc_num and
         lc_alloc_num = @lc_alloc_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cmdty_code,
      lc_alloc_amt_cap,
      lc_alloc_amt_curr_code,
      lc_alloc_amt_left,
      lc_alloc_amt_tol_oper,
      lc_alloc_amt_tol_pcnt,
      lc_alloc_base_price,
      lc_alloc_base_price_curr_code,
      lc_alloc_base_price_uom_code,
      lc_alloc_end_date,
      lc_alloc_formula_num,
      lc_alloc_last_bl_date,
      lc_alloc_max_amt,
      lc_alloc_max_qty,
      lc_alloc_min_amt,
      lc_alloc_min_qty,
      lc_alloc_num,
      lc_alloc_partial_ship_ind,
      lc_alloc_qty_tol_oper,
      lc_alloc_qty_tol_pcnt,
      lc_alloc_qty_uom_code,
      lc_alloc_start_date,
      lc_alloc_trans_ship_ind,
      lc_num,
      resp_trans_id,
      trans_id
   from dbo.aud_lc_allocation
   where lc_num = @lc_num and
         lc_alloc_num = @lc_alloc_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchLcAllocationRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchLcAllocationRevPK', NULL, NULL
GO
