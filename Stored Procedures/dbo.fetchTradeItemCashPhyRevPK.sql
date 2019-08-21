SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemCashPhyRevPK]
(
   @asof_trans_id      bigint,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.trade_item_cash_phy
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cfd_swap_ind,
      credit_term_code,
      efs_ind,
      execution_date,
      item_num,
      margin_conv_factor,
      max_qty,
      max_qty_uom_code,
      min_qty,
      min_qty_uom_code,
      order_num,
      pay_days,
      pay_term_code,
      resp_trans_id = null,
      settled_qty_uom_code,
      total_settled_qty,
      trade_exp_rec_ind,
      trade_imp_rec_ind,
      trade_num,
      trans_id
   from dbo.trade_item_cash_phy
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cfd_swap_ind,
      credit_term_code,
      efs_ind,
      execution_date,
      item_num,
      margin_conv_factor,
      max_qty,
      max_qty_uom_code,
      min_qty,
      min_qty_uom_code,
      order_num,
      pay_days,
      pay_term_code,
      resp_trans_id,
      settled_qty_uom_code,
      total_settled_qty,
      trade_exp_rec_ind,
      trade_imp_rec_ind,
      trade_num,
      trans_id
   from dbo.aud_trade_item_cash_phy
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemCashPhyRevPK] TO [next_usr]
GO
