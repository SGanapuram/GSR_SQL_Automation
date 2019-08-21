SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[quickfill_validate_trdprd]
(
   @commodity		   varchar(8) = null,
   @market 		     varchar(8) = null,
   @trdPrdDesc		 varchar(8) = null,
   @orderType		   varchar(8) = null,
   @tradeDate		   varchar(15) = null,
   @efpInd		     char(1) = null,
   @tradingPeriod	 varchar(8) output
)
as
set nocount on
declare @lastTradeDate varchar(25)
declare @optExpDate varchar(25)
declare @tradeMonths varchar(25)
declare @monthAsInt int
declare @isTradable char(1)
declare @commktKey int

   if (@commodity is null) or (@market is null) or (@trdPrdDesc is null)
      return -580

   select @tradingPeriod = null

   if (@orderType = 'F') 
   begin
      select @commktKey = cf.commkt_key, 
             @tradeMonths = commkt_trading_mth_ind 
      from dbo.commkt_future_attr cf, 
           dbo.commodity_market cm 
      where cm.cmdty_code = @commodity and 
            cm.mkt_code = @market and 
            cm.commkt_key = cf.commkt_key

      select @tradingPeriod = trading_prd, 
             @lastTradeDate = last_trade_date 
      from dbo.trading_period 
      where commkt_key = @commktKey and 
            trading_prd_desc = @trdPrdDesc 

      if (@tradingPeriod is null)
         return -581

      /* make sure it is not back dated */
      if (@efpInd != 'Y') and (datediff(day, @tradeDate, @lastTradeDate) < 0)
         return -582
      else if (@efpInd = 'Y') and (datediff(day, @tradeDate, @lastTradeDate) < -14)
         return -582
   end
   else 
   begin
      select @commktKey = co.commkt_key, 
             @tradeMonths = commkt_trading_mth_ind 
      from dbo.commkt_option_attr co, 
           dbo.commodity_market cm 
      where cm.cmdty_code = @commodity and 
            cm.mkt_code = @market and 
            cm.commkt_key = co.commkt_key

      select @tradingPeriod = trading_prd, 
             @optExpDate = opt_exp_date 
      from dbo.trading_period 
      where commkt_key = @commktKey and 
            trading_prd_desc = @trdPrdDesc 

      if (@tradingPeriod is null)
         return -581

      if (@optExpDate is not null) 
      begin
         /* make sure it has not expired */
         if (@efpInd != 'Y') and (datediff(day,@tradeDate,@optExpDate) < 0)
            return -582
         else if (@efpInd = 'Y') and (datediff(day,@tradeDate,@optExpDate) < -14)
            return -582
      end
   end

   /* make sure it is tradable period. */
   select @monthAsInt = convert(int,(right(@tradingPeriod,2)))
   select @isTradable = substring(@tradeMonths,@monthAsInt,1)
   if (lower(@isTradable) = 'n')
      return -583
   return 0
GO
GRANT EXECUTE ON  [dbo].[quickfill_validate_trdprd] TO [next_usr]
GO
