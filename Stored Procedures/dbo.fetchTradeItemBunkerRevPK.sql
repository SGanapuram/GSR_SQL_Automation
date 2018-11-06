SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemBunkerRevPK]
(
   @asof_trans_id      int,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.trade_item_bunker
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      credit_term_code,
      curr_exch_date,
      del_agent_num,
      del_date,
      del_term_code,
      delivery_mot,
      eta_date,
      exp_time_zone_code,
      handling_type_code,
      item_num,
      max_qty,
      max_qty_uom_code,
      min_qty,
      min_qty_uom_code,
      mot_code,
      order_num,
      pay_term_code,
      port_agent_num,
      port_loc_code,
      pricing_exp_date,
      resp_trans_id = null,
      storage_loc_code,
      tol_opt,
      tol_qty,
      tol_qty_uom_code,
      tol_sign,
      trade_num,
      trans_id,
      transp_price_amt,
      transp_price_curr_code,
      transp_price_uom_code
   from dbo.trade_item_bunker
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      credit_term_code,
      curr_exch_date,
      del_agent_num,
      del_date,
      del_term_code,
      delivery_mot,
      eta_date,
      exp_time_zone_code,
      handling_type_code,
      item_num,
      max_qty,
      max_qty_uom_code,
      min_qty,
      min_qty_uom_code,
      mot_code,
      order_num,
      pay_term_code,
      port_agent_num,
      port_loc_code,
      pricing_exp_date,
      resp_trans_id,
      storage_loc_code,
      tol_opt,
      tol_qty,
      tol_qty_uom_code,
      tol_sign,
      trade_num,
      trans_id,
      transp_price_amt,
      transp_price_curr_code,
      transp_price_uom_code
   from dbo.aud_trade_item_bunker
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemBunkerRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemBunkerRevPK', NULL, NULL
GO
