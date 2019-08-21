SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_SOURCE_in_price]
(
   @for_cmdty_code      char(8) = null,
   @for_mkt_code        char(8) = null
)
as
begin
set nocount on
declare @commkt_key    int

   if (@for_cmdty_code is null) and
      (@for_mkt_code is null)
   begin
      select '????', '?MISSING PARAMETER?'
      return 4
   end
  
   if not exists (select 1 
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

   select distinct cms.price_source_code, ps.price_source_name
   from dbo.commodity_market_source cms, 
        dbo.price_source ps
   where cms.commkt_key = @commkt_key and
         cms.price_source_code = ps.price_source_code
   order by ps.price_source_name
end
return
GO
GRANT EXECUTE ON  [dbo].[get_SOURCE_in_price] TO [next_usr]
GO
