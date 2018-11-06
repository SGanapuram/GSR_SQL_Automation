SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_price_detail]          
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
as          
select           
   p.price_quote_date,          
   p.commkt_key,          
   cm.cmdty_code,          
   cm.mkt_code,          
   cm.cmdty_short_name,          
   cm.mkt_short_name,          
   tp.trading_prd,          
   tp.trading_prd_desc,          
   tp.last_issue_date,          
   tp.last_trade_date,          
   p.price_source_code,          
   p.low_bid_price,          
   p.high_asked_price,          
   p.avg_closed_price,          
   cm.commkt_price_uom_code,          
   cm.commkt_curr_code,          
   cm.commkt_lot_size,          
   frm.commkt_key as UnderlyingCommkt,
   frm.underlying_cmdty_code,        
   frm.underlying_cmdty_short_name,     
   frm.underlying_mkt_code,       
   frm.underlying_mkt_short_name,          
   frm.underlying_price_source_code,          
   frm.underlying_trading_prd,          
   frm.underlying_quote_type,          
   frm.commkt_premium_diff,          
   frm.underlying_cmdty_short_name + '/' + frm.underlying_mkt_short_name + '/' + 
      frm.underlying_price_source_code + '/' + frm.underlying_trading_prd + '/' + frm.underlying_quote_type + ' ' +           
       case when frm.commkt_premium_diff = 0 then ''           
            when frm.commkt_premium_diff < 0 then '' + convert(varchar, frm.commkt_premium_diff)           
            when frm.commkt_premium_diff > 0 then '+' + convert(varchar, frm.commkt_premium_diff)           
       end          
from dbo.price p          
        join dbo.v_POSGRID_commkt_info cm with (nolock) 
           on p.commkt_key = cm.commkt_key           
        join dbo.trading_period tp with (nolock) 
           on tp.commkt_key = p.commkt_key and 
              tp.trading_prd = p.trading_prd          
        left outer join dbo.v_POSGRID_commkt_formula frm
           on frm.commkt_key = p.commkt_key and 
              frm.price_source_code = 'INTERNAL' and 
              frm.trading_prd = p.trading_prd          
GO
GRANT SELECT ON  [dbo].[v_POSGRID_price_detail] TO [next_usr]
GO
