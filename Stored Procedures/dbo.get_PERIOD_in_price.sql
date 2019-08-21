SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_PERIOD_in_price]
(
   @for_cmdty_code          char(8) = null,
   @for_mkt_code            char(8) = null,
   @for_price_source_code   char(8) = null
)
as
begin
set nocount on
declare @commkt_key    int

   if (@for_cmdty_code is null) and
      (@for_mkt_code is null) and
      (@for_price_source_code is null)
   begin
      select '????', '?MISSING PARAMETER?'
      return 4
   end
  
   if not Exists (select 1 
                  from dbo.commodity_market with (nolock)
                  where cmdty_code = @for_cmdty_code and
                        mkt_code = @for_mkt_code)
   begin
      select '????', '?FAILED TO GET CM?'
      return
   end

   select @commkt_key = commkt_key
   from dbo.commodity_market
   where cmdty_code = @for_cmdty_code and
         mkt_code = @for_mkt_code

   select trading_prd, trading_prd_desc
   from dbo.trading_period
   where trading_prd in (select distinct trading_prd
                         from dbo.price
                         where commkt_key = @commkt_key and
                               price_source_code = @for_price_source_code) and
         commkt_key = @commkt_key
   order by trading_prd
end
return
GO
GRANT EXECUTE ON  [dbo].[get_PERIOD_in_price] TO [next_usr]
GO
