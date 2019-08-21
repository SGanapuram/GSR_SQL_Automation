SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[inhouse_validate_trdprd]
(
   @commodity		  varchar(8) = null,
   @market 		    varchar(8) = null,
   @trdPrdDesc		varchar(8) = null,
   @orderType		  varchar(8) = null,
   @tradeDate		  varchar(15) = null,
   @tradingPeriod	varchar(8) output
)
as
set nocount on
declare @tradeMonths varchar(25)
declare @monthAsInt int
declare @isTradable char(1)
declare @commktKey int

   if (@commodity is null) or (@market is null) or (@trdPrdDesc is null)
      return -580

   select @tradingPeriod = null

   if (@orderType = 'F') 
      select @commktKey = cf.commkt_key, 
             @tradeMonths = commkt_trading_mth_ind 
      from dbo.commkt_future_attr cf, 
           dbo.commodity_market cm 
      where cm.cmdty_code = @commodity and 
            cm.mkt_code = @market and 
            cm.commkt_key = cf.commkt_key
   else
      select @commktKey = co.commkt_key, 
             @tradeMonths = commkt_trading_mth_ind 
      from dbo.commkt_option_attr co, 
           dbo.commodity_market cm 
      where cm.cmdty_code = @commodity and 
            cm.mkt_code = @market and 
            cm.commkt_key = co.commkt_key

   select @tradingPeriod = trading_prd 
   from dbo.trading_period 
   where commkt_key = @commktKey and 
         trading_prd_desc = @trdPrdDesc 
   if (@tradingPeriod is null)
      return -581

   /* make sure it is tradable period. */
   select @monthAsInt = convert(int,(right(@tradingPeriod,2)))
   select @isTradable = substring(@tradeMonths,@monthAsInt,1)
   if (lower(@isTradable) = 'n')
      return -583

   return 0
GO
GRANT EXECUTE ON  [dbo].[inhouse_validate_trdprd] TO [next_usr]
GO
