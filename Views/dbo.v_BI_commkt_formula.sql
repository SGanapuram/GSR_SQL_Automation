SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_BI_commkt_formula]   
(    
commkt_key,     
trading_prd,    
price_source_code,    
underlying_commkt_key,    
underlying_cmdty_code,    
underlying_cmdty_short_name,    
underlying_mkt_code,    
underlying_mkt_short_name,    
underlying_price_source_code,    
underlying_trading_prd,    
underlying_quote_type,    
commkt_premium_diff ,  
commkt_price_uom_code ,  
underlying_quote,
trans_id  
)    
AS    
select cmf.commkt_key, cmf.trading_prd ,cmf.price_source_code,cm.commkt_key 'UnderlyingCommkt', c.cmdty_code 'UnderlyingCmdtyCode',             
      c.cmdty_short_name 'UnderlylingCmdty', m.mkt_code 'UnderlyingMktCode',m.mkt_short_name 'UnderlyingMkt', convert(varchar,quote_price_source_code) 'UnderlyingSource',               
     convert(varchar,rtrim(quote_trading_prd)) 'UnderlyingTradingPrd', convert(varchar,quote_price_type) 'UnderlyingQuoteType', isnull(quote_diff,0) 'MTMQuoteDiff' , 
     isnull(cpa.commkt_price_uom_code,cfa.commkt_price_uom_code) commkt_price_uom_code, 

       c.cmdty_short_name+'/'+m.mkt_short_name+'/'+ convert(varchar,quote_price_source_code)+'/'+convert(varchar,rtrim(quote_trading_prd))+'/'+convert(varchar,quote_price_type) +' '+             
       case when isnull(quote_diff,0)=0 then ''             
         when isnull(quote_diff,0) < 0 then ''+convert(varchar,isnull(quote_diff,0))             
         when isnull(quote_diff,0) > 0 then '+'+convert(varchar,isnull(quote_diff,0))             
       end UnderlyingQuote   ,        
       
     cmf.trans_id  
   from commodity_market_formula cmf, simple_formula sf, commodity_market cm  
   LEFT OUTER JOIN commkt_physical_attr cpa ON cpa.commkt_key=cm.commkt_key  
   LEFT OUTER JOIN commkt_future_attr cfa ON cfa.commkt_key=cm.commkt_key  
   , commodity c, market m    , trading_period tp            
   where cmf.avg_closed_simple_formula_num=sf.simple_formula_num                
   and cm.cmdty_code=c.cmdty_code                
   and cm.mkt_code=m.mkt_code                
   and cm.commkt_key=quote_commkt_key                
   and tp.commkt_key=cmf.commkt_key    
   and tp.trading_prd=cmf.trading_prd    
   and tp.last_trade_date>=dateadd(mm,-2,getdate())    

GO
GRANT SELECT ON  [dbo].[v_BI_commkt_formula] TO [next_usr]
GO
