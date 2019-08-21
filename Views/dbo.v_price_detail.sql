SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_price_detail]          
(          
price_quote_date,          
commkt_key,          
cmdty_code,          
mkt_code,          
cmdty_short_name,          
mkt_short_name,          
trading_prd,          
trading_prd_desc,          
last_issue_date,          
last_trade_date,          
price_source_code,          
low_bid_price,          
high_asked_price,          
avg_closed_price,          
price_uom_code,          
price_curr_code,          
lot_size,       
underlying_commkt_key,   
underlying_cmdty_code,        
underlying_cmdty,          
underlying_mkt_code,        
underlying_mkt,          
underlying_source,          
underlying_trading_prd,          
underlying_quote_type,          
underlying_quote_diff,          
underlying_quote          
          
)          
AS          
  select           
  p.price_quote_date   PriceQuoteDate,          
  p.commkt_key,          
  c.cmdty_code,          
  m.mkt_code,          
  c.cmdty_short_name  Commodity,          
  m.mkt_short_name  Market,          
  tp.trading_prd,          
  tp.trading_prd_desc  TradingPrdDesc,          
  tp.last_issue_date,          
  tp.last_trade_date TradingExpiryDate,          
  p.price_source_code  PriceSource,          
  p.low_bid_price  Low,          
  p.high_asked_price  High,          
  p.avg_closed_price  AvgPrice,          
  --prevpr.avg_closed_price PreviousPrice,          
  --p.avg_closed_price - isnull(prevpr.avg_closed_price,0) 'DeltaPrice',          
  isnull(cmpa.commkt_price_uom_code,isnull(cmfa.commkt_price_uom_code,cmoa.commkt_price_uom_code)) PriceUom,          
  isnull(cmpa.commkt_curr_code,isnull(cmfa.commkt_curr_code,cmoa.commkt_curr_code)) PriceCurr,          
  isnull(cmfa.commkt_lot_size,cmoa.commkt_lot_size) LotSize,          
  UnderlyingCommkt,
  UnderlyingCmdtyCode,        
  UnderlylingCmdty,     
  UnderlyingMktCode,       
  UnderlyingMkt,          
  UnderlyingSource,          
  UnderlyingTradingPrd,          
  UnderlyingQuoteType,          
  MTMQuoteDiff UnderlyingQuoteDiff,          
  UnderlylingCmdty+'/'+UnderlyingMkt+'/'+UnderlyingSource+'/'+UnderlyingTradingPrd+'/'+UnderlyingQuoteType+' '+           
       case when MTMQuoteDiff=0 then ''           
         when MTMQuoteDiff < 0 then ''+convert(varchar,MTMQuoteDiff)           
         when MTMQuoteDiff > 0 then '+'+convert(varchar,MTMQuoteDiff)           
       end UnderlyingQuote          
--  prevpr.price_quote_date 'PrevPriceQuoteDate',          
  --prevpr.price_source_code 'PriceSource'          
  from           
  price p          
  join commodity_market cm on p.commkt_key = cm.commkt_key           
  join commodity c on c.cmdty_code = cm.cmdty_code          
  join market m on m.mkt_code = cm.mkt_code          
  join trading_period tp on tp.commkt_key = cm.commkt_key  and tp.trading_prd = p.trading_prd          
  left outer join commkt_physical_attr cmpa on cmpa.commkt_key = p.commkt_key          
  left outer join commkt_future_attr cmfa on cmfa.commkt_key = p.commkt_key          
  left outer join commkt_option_attr cmoa on cmoa.commkt_key = p.commkt_key          
  left outer join           
      (select cmf.commkt_key, cmf.trading_prd ,cmf.price_source_code,cm.commkt_key 'UnderlyingCommkt', c.cmdty_code 'UnderlyingCmdtyCode',       
      c.cmdty_short_name 'UnderlylingCmdty', m.mkt_code 'UnderlyingMktCode',m.mkt_short_name 'UnderlyingMkt', convert(varchar,quote_price_source_code) 'UnderlyingSource',         
     convert(varchar,rtrim(quote_trading_prd)) 'UnderlyingTradingPrd', convert(varchar,quote_price_type) 'UnderlyingQuoteType', isnull(quote_diff,0) 'MTMQuoteDiff'          
   from commodity_market_formula cmf, simple_formula sf, commodity_market cm, commodity c, market m          
   where cmf.avg_closed_simple_formula_num=sf.simple_formula_num          
   and cm.cmdty_code=c.cmdty_code          
   and cm.mkt_code=m.mkt_code          
   and cm.commkt_key=quote_commkt_key          
   ) frm ON frm.commkt_key=p.commkt_key and frm.price_source_code='INTERNAL' and frm.trading_prd=p.trading_prd          
   
GO
GRANT SELECT ON  [dbo].[v_price_detail] TO [next_usr]
GO
