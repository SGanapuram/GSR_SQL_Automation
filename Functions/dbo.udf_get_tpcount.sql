SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [dbo].[udf_get_tpcount]  
(  
 @commktKey int,  
 @tradingPrd char(8),
 @quoteDate   datetime
)  
returns char(10)  
as  
begin  
  
declare @NthNearby char(10)  
  
select  
@NthNearby =   
(case  
when spotCount = 0 then 'SPOT'  
when spotCount <10   
then 'SPOT0' +convert(char(2),  spotCount)  
else  
 'SPOT'+ convert(char(2), spotCount)  
end )  
from trading_period tp2  
inner join  
(select tp.trading_prd, (  
(select count(*) from trading_period tp where tp.commkt_key=@commktKey and last_trade_date>=@quoteDate)  
-count(*)  
) as spotCount from trading_period tp   
inner join trading_period tp3 on tp3.commkt_key=tp.commkt_key  
where tp.commkt_key=@commktKey and tp.trading_prd=@tradingPrd and  
 tp.last_trade_date > @quoteDate and tp3.last_trade_date > @quoteDate  
and datediff(dayofyear, tp.last_trade_date, tp3.last_trade_date)>=0  
group by tp.trading_prd  
)  
spotTPrd on spotTPrd.trading_prd=tp2.trading_prd  
where commkt_key=@commktKey and last_trade_date > @quoteDate  
return @NthNearby  
end
GO
GRANT EXECUTE ON  [dbo].[udf_get_tpcount] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_get_tpcount', NULL, NULL
GO
