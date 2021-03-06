SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchVoucherToVoucherCost]
(
   @asof_trans_id      bigint,
   @voucher_num        int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          cost_num,
          line_num,
          prov_amt,
          prov_price,
          prov_price_curr_code,
          prov_qty,
          prov_qty_uom_code,
          resp_trans_id = NULL,
          trans_id,
          voucher_cost_status,
          voucher_num
   from dbo.voucher_cost
   where voucher_num = @voucher_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          cost_num,
          line_num,
          prov_amt,
          prov_price,
          prov_price_curr_code,
          prov_qty,
          prov_qty_uom_code,
          resp_trans_id,
          trans_id,
          voucher_cost_status,
          voucher_num
   from dbo.aud_voucher_cost
   where voucher_num = @voucher_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchVoucherToVoucherCost] TO [next_usr]
GO
