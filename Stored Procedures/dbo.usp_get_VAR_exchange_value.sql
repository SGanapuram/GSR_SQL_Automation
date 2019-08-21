SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_VAR_exchange_value]   
   @dtRefDate datetime,    
   @chrCmdtyCode char(8),    
   @chrMktCode char(8),    
   @fltExchangePrice float OUTPUT   
AS  
  
--  
-- proc coming from Freight spEXCHANGE_VALUE   
--  
  
declare @iProcLines int  
select @iProcLines=1  
  
  
select  @fltExchangePrice=(select price.avg_closed_price FROM  commodity_market INNER JOIN  price ON  commodity_market.commkt_key =  price.commkt_key WHERE ((commodity_market.cmdty_code=@chrCmdtyCode ) AND (commodity_market.mkt_code=@chrMktCode) AND (price.price_quote_date=CONVERT(DATETIME, @dtRefDate, 102))))  
  
IF  @fltExchangePrice is null  
    BEGIN  
        WHILE @iProcLines  <=7  
        BEGIN  
           select @dtRefDate = DATEADD(day, -1, @dtRefDate)  
            select  @fltExchangePrice=(select price.avg_closed_price FROM  commodity_market cm INNER JOIN  price ON  cm.commkt_key =  price.commkt_key WHERE ((cm.cmdty_code=@chrCmdtyCode ) AND (cm.mkt_code=@chrMktCode)  
                AND price.trading_prd = 'SPOT'  
                and price.price_source_code =  cm.mtm_price_source_code                             
                AND (price.price_quote_date=CONVERT(DATETIME, @dtRefDate, 102))))  
  
            if  @fltExchangePrice is null  
                select @iProcLines=@iProcLines+1  
            else  
                select @iProcLines=8  
        END  
        
  
    END  
select @fltExchangePrice  
GO
GRANT EXECUTE ON  [dbo].[usp_get_VAR_exchange_value] TO [next_usr]
GO
