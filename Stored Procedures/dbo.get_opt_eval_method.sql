SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_opt_eval_method]
(
   @by_commkt_key          int = null,
   @by_price_quote_date    datetime = null
)
as
begin
set nocount on

   if (@by_commkt_key is null) or 
      (@by_price_quote_date is null) 
      return 4

   select trading_prd,
          trading_prd_desc,
          opt_eval_method
   from dbo.trading_period
   where commkt_key = @by_commkt_key and
         (last_trade_date >= dateadd(day, -60, @by_price_quote_date) or
          trading_prd like 'SPOT%')
   order by trading_prd
end
return
GO
GRANT EXECUTE ON  [dbo].[get_opt_eval_method] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_opt_eval_method', NULL, NULL
GO
