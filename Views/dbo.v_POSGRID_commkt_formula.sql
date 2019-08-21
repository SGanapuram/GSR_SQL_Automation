SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_commkt_formula]  
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
   commkt_premium_diff,
   commkt_price_uom_code,
   underlying_quote,
   trans_id
)  
as  
select cmf.commkt_key, 
       cmf.trading_prd,
       cmf.price_source_code,
       sf.commkt_key, 
       sf.cmdty_code,           
       sf.cmdty_short_name, 
       sf.mkt_code,
       sf.mkt_short_name, 
       convert(varchar, sf.quote_price_source_code),             
       convert(varchar, sf.quote_trading_prd), 
       convert(varchar, sf.quote_price_type), 
       isnull(sf.quote_diff, 0), 
       sf.commkt_price_uom_code, 
       sf.cmdty_short_name + '/' + sf.mkt_short_name + '/' + 
          convert(varchar, sf.quote_price_source_code) + '/' + 
             convert(varchar,rtrim(sf.quote_trading_prd)) + '/'+
                convert(varchar, sf.quote_price_type) + ' ' +             
                  case when isnull(sf.quote_diff, 0) = 0 
                          then ''             
                       when isnull(sf.quote_diff, 0) < 0 
                          then '' + convert(varchar, isnull(sf.quote_diff, 0))             
                       when isnull(sf.quote_diff, 0) > 0 
                          then '+' + convert(varchar, isnull(sf.quote_diff, 0))             
                  end,               
       cmf.trans_id
from dbo.commodity_market_formula cmf with (nolock) 
        INNER JOIN dbo.v_POSGRID_simple_formula_info sf with (nolock)
           ON cmf.avg_closed_simple_formula_num = sf.simple_formula_num 
GO
GRANT SELECT ON  [dbo].[v_POSGRID_commkt_formula] TO [next_usr]
GO
