SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_MARKET_in_price]
(
   @for_cmdty_code      char(8) = null
)
as
begin
set nocount on

   if (@for_cmdty_code is null) 
   begin
      select '????', '?MISSING PARAMETER?'
      return 4
   end
  
   select distinct m.mkt_code, m.mkt_short_name
   from dbo.commodity_market cm, 
        dbo.market m
   where cm.cmdty_code = @for_cmdty_code and
         cm.mkt_code = m.mkt_code
   order by m.mkt_short_name
end
return
GO
GRANT EXECUTE ON  [dbo].[get_MARKET_in_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_MARKET_in_price', NULL, NULL
GO
