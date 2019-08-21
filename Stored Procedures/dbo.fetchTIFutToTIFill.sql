SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTIFutToTIFill]
(
   @asof_trans_id      bigint,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          broker_fifo_qty,
          bsi_fill_num,
          efp_post_date,
          external_trade_num,
          fifo_qty,
          fill_closed_qty,
          fill_date,
          fill_price,
          fill_price_curr_code,
          fill_price_uom_code,
          fill_qty,
          fill_qty_uom_code,
          fill_status,
          in_out_house_ind,
          inhouse_fill_num,
          inhouse_item_num,
          inhouse_order_num,
          inhouse_trade_num,
          item_fill_num,
          item_num,
          order_num,
          outhouse_acct_alloc,
          outhouse_profit_center,
          port_match_qty,
          resp_trans_id = NULL,
          trade_num,
          trans_id
   from dbo.trade_item_fill
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          broker_fifo_qty,
          bsi_fill_num,
          efp_post_date,
          external_trade_num,
          fifo_qty,
          fill_closed_qty,
          fill_date,
          fill_price,
          fill_price_curr_code,
          fill_price_uom_code,
          fill_qty,
          fill_qty_uom_code,
          fill_status,
          in_out_house_ind,
          inhouse_fill_num,
          inhouse_item_num,
          inhouse_order_num,
          inhouse_trade_num,
          item_fill_num,
          item_num,
          order_num,
          outhouse_acct_alloc,
          outhouse_profit_center,
          port_match_qty,
          resp_trans_id,
          trade_num,
          trans_id
   from dbo.aud_trade_item_fill
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchTIFutToTIFill] TO [next_usr]
GO
