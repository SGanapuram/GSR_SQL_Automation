SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchVoucherCostRevPK]
(
   @asof_trans_id      bigint,
   @cost_num           int,
   @voucher_num        int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.voucher_cost
where voucher_num = @voucher_num and
      cost_num = @cost_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cost_num,
      line_num,
      prov_amt,
      prov_price,
      prov_price_curr_code,
      prov_qty,
      prov_qty_uom_code,
      resp_trans_id = null,
      trans_id,
      voucher_cost_status,
      voucher_num
   from dbo.voucher_cost
   where voucher_num = @voucher_num and
         cost_num = @cost_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
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
         cost_num = @cost_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchVoucherCostRevPK] TO [next_usr]
GO
