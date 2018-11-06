SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_option_strikes]
(
   @by_commkt_key          int = null,
   @by_price_source_code   varchar(8) = null,
   @by_price_quote_date    datetime = null,
   @by_earliest_period     varchar(30) = null
)
as
begin
set nocount on

   if (@by_commkt_key is null) or 
      (@by_price_source_code is null) or 
      (@by_price_quote_date is null) or
      (@by_earliest_period is null) 
      return 4

   create table #option_strike_temp 
   (       
       opt_strike_price    float     not null
   )
   create index option_strike_temp_idx1
        on #option_strike_temp (opt_strike_price)
     
   insert into #option_strike_temp
   select distinct opt.opt_strike_price
   from dbo.trading_period tp, 
        dbo.option_strike opt
   where tp.commkt_key = @by_commkt_key and
         tp.trading_prd LIKE 'SPOT%' and
         opt.commkt_key = @by_commkt_key and
         tp.trading_prd = opt.trading_prd


   insert into #option_strike_temp
   select distinct opt.opt_strike_price
   from dbo.trading_period tp, 
        dbo.option_strike opt
   where tp.commkt_key = @by_commkt_key and
         (NOT tp.trading_prd LIKE 'SPOT%' and 
          convert(int, substring(tp.trading_prd, 1, 6)) >= convert(int, @by_earliest_period)) and 
         opt.commkt_key = @by_commkt_key and
         tp.trading_prd = opt.trading_prd 


   select distinct opt_strike_price
   from #option_strike_temp
   where opt_strike_price > 0.0
   order by opt_strike_price

   drop table #option_strike_temp
end
return
GO
GRANT EXECUTE ON  [dbo].[get_option_strikes] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_option_strikes', NULL, NULL
GO
