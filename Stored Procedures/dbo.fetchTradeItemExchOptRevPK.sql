SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemExchOptRevPK]
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
from dbo.trade_item_exch_opt
where trade_num = @trade_num and
      order_num = @order_num and
      item_num = @item_num
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
	  auto_exercise,
      avg_fill_price,
      clr_brkr_comm_amt,
      clr_brkr_comm_curr_code,
      clr_brkr_comm_uom_code,
      clr_brkr_cont_num,
      clr_brkr_num,
      clr_brkr_ref_num,
      exec_type_code,
	  exer_commkt_key,
      exp_date,
      exp_zone_code,
      fill_qty_uom_code,
      item_num,
      opt_type,
      order_num,
      premium,
      premium_curr_code,
      premium_pay_date,
      premium_uom_code,
	  price_date_from,
	  price_date_to,
      price_source_code,
      put_call_ind,
      resp_trans_id = null,
      settlement_type,
      strike_excer_date,
      strike_price,
      strike_price_curr_code,
      strike_price_uom_code,
      surrender_qty,
      total_fill_qty,
      trade_num,
      trans_id,
      use_in_fifo_ind
   from dbo.trade_item_exch_opt
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
	  auto_exercise,
      avg_fill_price,
      clr_brkr_comm_amt,
      clr_brkr_comm_curr_code,
      clr_brkr_comm_uom_code,
      clr_brkr_cont_num,
      clr_brkr_num,
      clr_brkr_ref_num,
      exec_type_code,
	  exer_commkt_key,
      exp_date,
      exp_zone_code,
      fill_qty_uom_code,
      item_num,
      opt_type,
      order_num,
      premium,
      premium_curr_code,
      premium_pay_date,
      premium_uom_code,
	  price_date_from,
	  price_date_to,
      price_source_code,
      put_call_ind,
      resp_trans_id,
      settlement_type,
      strike_excer_date,
      strike_price,
      strike_price_curr_code,
      strike_price_uom_code,
      surrender_qty,
      total_fill_qty,
      trade_num,
      trans_id,
      use_in_fifo_ind
   from dbo.aud_trade_item_exch_opt
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemExchOptRevPK] TO [next_usr]
GO
