SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_search_desc]
as 
set nocount on

   update #inhouse_search 
   set buy_port_short_name = port_short_name
   from #inhouse_search, 
        dbo.portfolio
   where buy_port_num = port_num

   update #inhouse_search 
   set sell_port_short_name = port_short_name
   from #inhouse_search, 
        dbo.portfolio
   where sell_port_num = port_num

   select a.trade_num,
	        a.order_num,
	        a.item_num,
	        a.trader_init,
	        a.contr_date,
	        a.creation_date,
	        a.creator_init,
	        a.buy_trader_init,
	        a.buy_port_short_name,
	        a.order_type_code,
	        a.p_s_ind,
	        a.cmdty_code,
	        a.risk_mkt_code,
	        a.title_mkt_code,
	        a.trading_prd,
	        a.contr_qty_uom_code,
	        a.item_type,
	        a.total_fill_qty,
	        a.avg_price,
	        a.price_curr_code,
	        a.price_uom_code,
	        a.put_call_ind,
	        a.opt_type,
	        a.strike_price,
	        a.strike_price_uom_code,
	        a.strike_price_curr_code,
	        a.sell_trader_init,
	        a.sell_port_short_name,
	        a.trd_prd_desc,
	        a.from_del_date,
	        a.to_del_date
   from #inhouse_search a	
   order by creation_date, a.item_num 
return 0         
GO
GRANT EXECUTE ON  [dbo].[inhouse_search_desc] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'inhouse_search_desc', NULL, NULL
GO
