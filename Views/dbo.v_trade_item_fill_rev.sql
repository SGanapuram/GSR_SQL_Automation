SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_fill_rev]
(
   trade_num,
   order_num,
   item_num,
   item_fill_num,
   fill_qty,
   fill_qty_uom_code,
   fill_price,
   fill_price_curr_code,
   fill_price_uom_code,
   fill_status,
   fill_date,
   bsi_fill_num,
   efp_post_date,
   inhouse_trade_num,
   inhouse_order_num,
   inhouse_item_num,
   inhouse_fill_num,
   in_out_house_ind,
   outhouse_profit_center,
   outhouse_acct_alloc,
   fill_closed_qty,
   broker_fifo_qty,
   port_match_qty,    
   fifo_qty,  
   external_trade_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   trade_num,
   order_num,
   item_num,
   item_fill_num,
   fill_qty,
   fill_qty_uom_code,
   fill_price,
   fill_price_curr_code,
   fill_price_uom_code,
   fill_status,
   fill_date,
   bsi_fill_num,
   efp_post_date,
   inhouse_trade_num,
   inhouse_order_num,
   inhouse_item_num,
   inhouse_fill_num,
   in_out_house_ind,
   outhouse_profit_center,
   outhouse_acct_alloc,
   fill_closed_qty,
   broker_fifo_qty,
   port_match_qty,    
   fifo_qty, 
   external_trade_num, 
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_fill
GO
GRANT SELECT ON  [dbo].[v_trade_item_fill_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_fill_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_fill_rev', NULL, NULL
GO
