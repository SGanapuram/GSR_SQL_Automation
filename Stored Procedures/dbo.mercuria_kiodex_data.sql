SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[mercuria_kiodex_data]               
@ContrDate datetime='01/01/1990'              
AS              
              
BEGIN              
              
DECLARE @BusnDate datetime              
              
select @BusnDate=max(pl_asof_date) from portfolio_profit_loss where port_num in (13113,36972,13119) --group by port_num              
              
--mercuria_kiodex_code              
select  case when i.risk_mkt_code in ('IPE','ICE') then 'ICE'            
    when i.risk_mkt_code in ('NYMEX','CME','CBOT') then 'CME'            
  else  i.risk_mkt_code end 'ClearingBroker',               
 convert(char(12),@BusnDate,111) 'BusinessDate' ,               
 convert(varchar,i.trade_num)+'/'+convert(varchar,i.order_num)+'/'+convert(varchar,i.item_num) 'TradeKey',              
 convert(char(12), t.creation_date,111) 'ExecTime',               
 (case when i.contr_qty_uom_code='MB' then 1000 else 1 end) *(case when i.p_s_ind='S' then -1 else 1 end * tif.total_fill_qty) 'ContrQty',              
 case when i.contr_qty_uom_code='LOTS' then 'LOT'               
      when i.contr_qty_uom_code='STU' then 'TON'               
      when i.contr_qty_uom_code='THMS' then 'Therm'               
   when i.contr_qty_uom_code='MB' then 'BBL'               
 else i.contr_qty_uom_code                
 end contr_qty_uom_code,              
 '' 'QtyGranularity',              
 isnull(rtrim(exch_code)+'|'+pc.product_code ,rtrim(i.risk_mkt_code)+'|'+i.cmdty_code) 'ExchangeCommodity',               
convert(char(12), tp.first_del_date,111) 'StartDate',               
convert(char(12),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,tp.last_del_date)+1,0)),111)   'EndDate',              
(case when i.price_curr_code='USD' and i.cmdty_code='SOYOIL' and i.risk_mkt_code='CBOT' then 100 else 1 end) * round(isnull(tif.avg_fill_price,0),6) 'Price',              
case  when i.price_uom_code='STU' then 'TON'               
 when i.price_uom_code='THMS' then 'Therm'               
 else i.price_uom_code               
end 'PriceUnit',              
case  when i.price_curr_code='EURO' then 'EUR'               
 when i.price_curr_code='GBX' then 'GBP'               
 when i.price_curr_code='POUND' then 'GBP'        
 when i.price_curr_code='USC' then  'USD Cents'        
 when i.price_curr_code='USD' and i.cmdty_code='SOYOIL' and i.risk_mkt_code='CBOT' then 'USD Cents'    
 when i.price_curr_code='USD' and isnull(rtrim(exch_code)+'|'+pc.product_code ,rtrim(i.risk_mkt_code)+'|'+i.cmdty_code) in ('CBT|C','CBT|S','CBT|W','CME|48') then 'USD Cents'     
else i.price_curr_code              
END  'PriceCurrency',              
'' 'Put/Call',              
'' 'StrikePrice',              
'' 'Void',              
CASE               
 WHEN clr.acct_short_name like 'B82%' THEN 'BNP Paribas Commodity Futures'              
 WHEN clr.acct_full_name like 'PRUDENTIAL%' THEN 'Prudential Bache Commodities'              
 WHEN  clr.acct_short_name like '0LC%' THEN 'Prudential Bache Commodities'              
 WHEN  clr.acct_short_name like 'ZSD%' THEN 'ADM Investor Services'              
 WHEN  clr.acct_short_name like '2000M606%' THEN 'Newedge Group SNC'              
 WHEN  clr.acct_short_name like 'M58%' THEN 'Newedge Group SNC'              
 WHEN  clr.acct_full_name like 'NEWEDGE%' THEN 'Newedge Group SNC'              
 WHEN  clr.acct_full_name like 'CITI%' THEN 'Citigroup Global Markets'              
 WHEN  clr.acct_full_name like 'NS2J%' THEN 'Citigroup Global Markets'              
 WHEN  clr.acct_full_name like 'NS2K%' THEN 'Citigroup Global Markets'              
 WHEN  clr.acct_full_name like 'FORTIS%' THEN 'Fortis Clearing Americas'              
 WHEN  clr.acct_full_name like 'FIMAT%' THEN 'Fimat'              
 WHEN  clr.acct_full_name like 'MF%' THEN 'MF Global'              
 WHEN  clr.acct_short_name like 'MF6%' THEN 'MF Global'            
 WHEN  clr.acct_short_name like 'RBS%' THEN 'The Royal Bank of Scotland'          
 ELSE              
 clr.acct_full_name               
END 'ClearingBrokerName',              
'' 'Counterparty',              
clr.acct_short_name 'ClearingBrokerAccount',              
brkr.acct_short_name 'ExecutionBroker',              
b.acct_short_name 'BookingCompany',              
pt.tag_value 'Profit Center'              
from trade t, trade_order to1,              
trade_item i    
INNER JOIN commodity_market cm ON cm.cmdty_code=i.cmdty_code and cm.mkt_code=i.risk_mkt_code              
INNER JOIN trading_period tp ON tp.commkt_key=cm.commkt_key and tp.trading_prd=i.trading_prd              
INNER JOIN trade_item_fut tif ON i.trade_num=tif.trade_num and i.order_num=tif.order_num and i.item_num=tif.item_num               
INNER JOIN trade_item_dist tid ON i.trade_num=tid.trade_num and i.order_num=tid.order_num and i.item_num=tid.item_num               
--LEFT OUTER JOIN comment cm ON i.cmnt_num = cm.cmnt_num              
LEFT OUTER JOIN mercuria_kiodex_code pc ON pc.cmdty_code=i.cmdty_code and pc.mkt_code=i.risk_mkt_code and order_type_code<>'EXCHGOPT'              
LEFT OUTER JOIN portfolio_tag pt ON i.real_port_num = pt.port_num and pt.tag_name = 'PRFTCNTR'               
LEFT OUTER JOIN account clr ON tif.clr_brkr_num = clr.acct_num              
LEFT OUTER JOIN account brkr ON i.brkr_num = brkr.acct_num,              
account b              
where i.item_type in ( 'F' ,'X')              
and t.inhouse_ind = 'N'              
and to1.trade_num=i.trade_num and to1.order_num=i.order_num              
and ((to1.order_type_code not in ('EXCHGOPT','EFPEXCH') )              
 OR (to1.order_type_code in ('EXCHGOPT','EFPEXCH')               
 AND tid.what_if_ind = 'N'                 
 AND tid.is_equiv_ind = 'N'                 
 AND tid.real_synth_ind = 'R'                 
 AND tid.dist_type = 'D'   )              
     )              
and t.trade_num = i.trade_num               
and i.booking_comp_num = b.acct_num               
and clr.acct_short_name not in ('VARTEST EXC BRK','VARTEST CPTY','INTERNAL')              
and tp.last_trade_date >=CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103)                
and risk_mkt_code not in ('CAPESIZE')              
and isnull(contr_qty,0)<>0 and  isnull(tif.avg_fill_price,0)<>0               
and contr_date<convert(char,getdate(),101)              
and contr_date>=@ContrDate              
--order by isnull(exch_code+'|'+pc.product_code ,i.risk_mkt_code+'|'+i.cmdty_code)               
and clr.acct_short_name not in ('B82A58','B82A59','B82A60','B82A61','B82A62','B82A63','B82A64','B82B44','B82B45','B82B57',        
'B82A5','B82A58','B82A12','B82A20','B82A21','B82A22','B82A23','B82A24','B82A25')        
        
             
              
              
              
union              
              
              
              
select   CASE WHEN a.acct_short_name in ('NYMEX','DME','CBOT','CME') then 'CME'               
    WHEN a.acct_short_name='THE ICE' then 'ICE'             
    else a.acct_short_name               
   END   'Trader',               
 convert(char(12), @BusnDate,111) 'BusinessDate',               
 convert(varchar,i.trade_num)+'/'+convert(varchar,i.order_num)+'/'+convert(varchar,i.item_num) 'TradeKey',              
 convert(char(12), t.creation_date,111) 'ExecTime',               
  (case when i.contr_qty_uom_code='MB' then 1000 else 1 end)               
   *(case when i.p_s_ind='S' then -1 else 1 end * i.contr_qty)               
 / -- Divide by for converting qty from BBL to MT for specific products              
 (CASE               
  when cm.tiny_cmnt='NOB' and i.contr_qty_uom_code='BBL' then 8.9               
  when cm.tiny_cmnt='EOB' and i.contr_qty_uom_code='BBL' then 8.33               
  when cm.tiny_cmnt='GOC' and i.contr_qty_uom_code='BBL' then 7.45               
  ELSE 1              
   END              
   ) 'ContrQty',              
              
 case when i.contr_qty_uom_code='LOTS' then 'LOT'               
      when i.contr_qty_uom_code='STU' then 'TON'               
      when i.contr_qty_uom_code='THMS' then 'Therm'               
   when i.contr_qty_uom_code='MB' then 'BBL'               
   when cm.tiny_cmnt in ('NOB','EOB','GOC') and i.contr_qty_uom_code='BBL' then 'MT'               
 else i.contr_qty_uom_code                
 end contr_qty_uom_code,              
 '' 'QtyGranularity',              
 CASE  WHEN a.acct_short_name='NYMEX' then 'NYM'               
       WHEN a.acct_short_name='THE ICE' then 'IPE' else a.acct_short_name               
 END               
 +'|'+                
 UPPER(rtrim(case when len(i.idms_acct_alloc)<>0 then i.idms_acct_alloc else  case when cm.tiny_cmnt='BSP' then 'I' else cm.tiny_cmnt end end ))      
 'Exchange|Commodity',               
 case when cm.tiny_cmnt in ('QX','QP','UCA','WCC','06','S') THEN              
  CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(ac.accum_end_date)-1),ac.accum_end_date),111) ELSE convert(char(12), ac.accum_start_date,111)               
 end 'StartDate',              
  /* case when cm.tiny_cmnt in ('QX','QP','UCA','WCC','06','S') THEN              
    convert(char(12),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,ac.accum_end_date)+1,0)),111) ELSE convert(char(12), ac.accum_end_date,111)                
   end */  
convert(char(12),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,ac.accum_end_date)+1,0)),111) 'EndDate',          
 round(CONVERT(float,prc_desc.formula_body_string) * -1,6)  'Price',              
 case  when i.price_uom_code='STU' then 'TON'                
  when i.price_uom_code='THMS' then 'Therm'               
  else i.price_uom_code               
 end 'PriceUnit',              
 case  when i.price_curr_code='EURO' then 'EUR'               
  when i.price_curr_code='GBX' then 'GBP'               
  when i.price_curr_code='POUND' then 'GBP'      
 when i.price_curr_code='USC' then  'USD Cents'    
 else i.price_curr_code              
 END  'PriceCurrency',              
 '' 'Put/Call',              
 '' 'Strike Price',              
 '' 'Void',              
 CASE               
  WHEN ab.acct_short_name like 'B82%' THEN 'BNP Paribas Commodity Futures'              
  WHEN ab.acct_full_name like 'PRUDENTIAL%' THEN 'Prudential Bache Commodities'              
  WHEN  ab.acct_short_name like '0LC%' THEN 'Prudential Bache Commodities'              
  WHEN  ab.acct_short_name like 'ZSD%' THEN 'ADM Investor Services'              
  WHEN  ab.acct_short_name like '2000M606%' THEN 'Newedge Group SNC'              
  WHEN  ab.acct_short_name like 'M58%' THEN 'Newedge Group SNC'              
  WHEN  ab.acct_full_name like 'NEWEDGE%' THEN 'Newedge Group SNC'              
  WHEN  ab.acct_full_name like 'CITI%' THEN 'Citigroup Global Markets'            
  WHEN  ab.acct_full_name like 'NS2J%' THEN 'Citigroup Global Markets'                  
  WHEN  ab.acct_full_name like 'NS2K%' THEN 'Citigroup Global Markets'                  
  WHEN  ab.acct_full_name like 'FORTIS%' THEN 'Fortis Clearing Americas'              
  WHEN  ab.acct_full_name like 'FIMAT%' THEN 'Fimat'              
  WHEN  ab.acct_full_name like 'MF%' THEN 'MF Global'              
  WHEN  ab.acct_short_name like 'MF6%' THEN 'MF Global'            
  WHEN  ab.acct_short_name like 'RBS%' THEN 'The Royal Bank of Scotland'          
 ELSE              
  ab.acct_full_name               
 END 'ClearingBrokerName',               
 a.acct_short_name 'Counterparty',              
 ab.acct_short_name 'ClearingBrokerAccount',              
 brkr.acct_short_name 'ExecutionBroker',              
 b.acct_short_name 'BookingCompany',              
 pt.tag_value 'ProfitCenter'              
from trade t, trade_order to1,              
trade_item i               
LEFT OUTER JOIN comment cm ON i.cmnt_num = cm.cmnt_num              
LEFT OUTER JOIN portfolio_tag pt ON i.real_port_num = pt.port_num and pt.tag_name = 'PRFTCNTR'               
LEFT OUTER JOIN account ab ON i.exch_brkr_num = ab.acct_num              
LEFT OUTER JOIN account brkr ON i.brkr_num = brkr.acct_num,              
account a,account b,              
accumulation ac              
LEFT OUTER JOIN (select distinct f.formula_num, tf.trade_num,  tf.order_num,tf.item_num,          formula_precision,formula_rounding_level,price_term_start_date,price_term_end_date , all_quotes_reqd_ind, roll_days,formula_body_string              
    From formula f, avg_buy_sell_price_term absp,trade_formula tf               
    LEFT OUTER JOIN formula_body fb ON fb.formula_num = tf.formula_num AND fb.formula_body_type = 'M'                
  where f.formula_num=tf.formula_num              
    and f.formula_num=absp.formula_num)               
prc_desc ON prc_desc.trade_num=ac.trade_num and prc_desc.order_num=ac.order_num               
  and prc_desc.item_num=ac.item_num              
where i.item_type = 'C'               
and to1.trade_num=i.trade_num and to1.order_num=i.order_num              
and to1.order_type_code in ('SWAP','SWAPFLT')              
and ac.trade_num = i.trade_num and ac.order_num = i.order_num and ac.item_num = i.item_num              
and t.trade_num = i.trade_num               
and a.acct_num = t.acct_num and a.acct_short_name in ('NYMEX','THE ICE')              
and i.booking_comp_num = b.acct_num               
and ac.accum_end_date >= CONVERT(DATETIME, CONVERT(VARCHAR(6), Getdate(), 112)+'01', 103)              
and isnull(contr_qty,0)<>0              
and isnull(round(CONVERT(float,prc_desc.formula_body_string) * -1,6),0) <>0              
and contr_date<convert(char,getdate(),101)              
and contr_date>=@ContrDate              
and ab.acct_short_name not in ('B82A58','B82A59','B82A60','B82A61','B82A62','B82A63','B82A64','B82B44','B82B45','B82B57',        
'B82A5','B82A58','B82A12','B82A20','B82A21','B82A22','B82A23','B82A24','B82A25')        
        
            
union        
              
              
select  case when i.risk_mkt_code in ('IPE','ICE') then 'ICE'            
    when i.risk_mkt_code in ('NYMEX','CME','CBOT') then 'CME'            
  else  i.risk_mkt_code end 'ClearingBroker',                 
 convert(char(12),@BusnDate,111) 'BusinessDate' ,               
 convert(varchar,i.trade_num)+'/'+convert(varchar,i.order_num)+'/'+convert(varchar,i.item_num) 'TradeKey',              
 convert(char(12), t.creation_date,111) 'ExecTime',               
 (case when i.contr_qty_uom_code='MB' then 1000 else 1 end) *(case when i.p_s_ind='S' then -1 else 1 end * i.contr_qty) 'ContrQty',              
 case when i.contr_qty_uom_code='LOTS' then 'LOT'               
      when i.contr_qty_uom_code='STU' then 'TON'               
      when i.contr_qty_uom_code='THMS' then 'Therm'               
   when i.contr_qty_uom_code='MB' then 'BBL'               
 else i.contr_qty_uom_code                
 end contr_qty_uom_code,              
 '' 'QtyGranularity',              
 isnull(rtrim(exch_code)+'|'+pc.product_code ,rtrim(i.risk_mkt_code)+'|'+i.cmdty_code) 'ExchangeCommodity',               
convert(char(12), tp.first_del_date,111) 'StartDate',               
convert(char(12),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,tp.last_del_date)+1,0)),111) 'EndDate',  
--convert(char(12), tp.last_del_date,111) 'EndDate',              
(case when i.price_curr_code='USD' and i.cmdty_code='SOYOIL' and i.risk_mkt_code='CBOT' then 100 else 1 end) * round(isnull(tif.avg_fill_price,0),6) 'Price',              
case  when i.price_uom_code='STU' then 'TON'               
 when i.price_uom_code='THMS' then 'Therm'               
 else i.price_uom_code               
end 'PriceUnit',              
case  when i.price_curr_code='EURO' then 'EUR'               
 when i.price_curr_code='GBX' then 'GBP'               
 when i.price_curr_code='POUND' then 'GBP'       
 when i.price_curr_code='USC' then  'USD Cents'    
 when i.price_curr_code='USD' and i.cmdty_code='SOYOIL' and i.risk_mkt_code='CBOT' then 'USD Cents'           
 when i.price_curr_code='USD' and isnull(rtrim(exch_code)+'|'+pc.product_code ,rtrim(i.risk_mkt_code)+'|'+i.cmdty_code) in ('CBT|C','CBT|S','CBT|W','CME|48') then 'USD Cents'     
 else i.price_curr_code              
END  'PriceCurrency',              
put_call_ind 'Put/Call',              
strike_price 'StrikePrice',              
'' 'Void',              
CASE               
 WHEN clr.acct_short_name like 'B82%' THEN 'BNP Paribas Commodity Futures'              
 WHEN clr.acct_full_name like 'PRUDENTIAL%' THEN 'Prudential Bache Commodities'              
 WHEN  clr.acct_short_name like '0LC%' THEN 'Prudential Bache Commodities'              
 WHEN  clr.acct_short_name like 'ZSD%' THEN 'ADM Investor Services'              
 WHEN  clr.acct_short_name like '2000M606%' THEN 'Newedge Group SNC'              
 WHEN  clr.acct_short_name like 'M58%' THEN 'Newedge Group SNC'            
 WHEN  clr.acct_full_name like 'NEWEDGE%' THEN 'Newedge Group SNC'              
 WHEN  clr.acct_full_name like 'CITI%' THEN 'Citigroup Global Markets'      
 WHEN  clr.acct_full_name like 'NS2J%' THEN 'Citigroup Global Markets'    
 WHEN  clr.acct_full_name like 'NS2K%' THEN 'Citigroup Global Markets'    
 WHEN  clr.acct_full_name like 'FORTIS%' THEN 'Fortis Clearing Americas'              
 WHEN  clr.acct_full_name like 'FIMAT%' THEN 'Fimat'              
 WHEN  clr.acct_full_name like 'MF%' THEN 'MF Global'              
 WHEN  clr.acct_short_name like 'MF6%' THEN 'MF Global'            
 WHEN  clr.acct_short_name like 'RBS%' THEN 'The Royal Bank of Scotland'          
 ELSE              
 clr.acct_full_name               
END 'ClearingBrokerName',              
'' 'Counterparty',              
clr.acct_short_name 'ClearingBrokerAccount',              
brkr.acct_short_name 'ExecutionBroker',              
b.acct_short_name 'BookingCompany',              
pt.tag_value 'Profit Center'      
from trade t,              
trade_item i               
INNER JOIN trade_order to1 ON to1.trade_num=i.trade_num and to1.order_num=i.order_num              
INNER JOIN commodity_market cm ON cm.cmdty_code=i.cmdty_code and cm.mkt_code=i.risk_mkt_code              
INNER JOIN trading_period tp ON tp.commkt_key=cm.commkt_key and tp.trading_prd=i.trading_prd              
INNER JOIN trade_item_exch_opt tif ON i.trade_num=tif.trade_num and i.order_num=tif.order_num and i.item_num=tif.item_num               
INNER JOIN trade_item_dist tid ON i.trade_num=tid.trade_num and i.order_num=tid.order_num and i.item_num=tid.item_num               
LEFT OUTER JOIN mercuria_kiodex_code pc ON pc.cmdty_code=i.cmdty_code and pc.mkt_code=i.risk_mkt_code and pc.order_type_code=to1.order_type_code              
LEFT OUTER JOIN portfolio_tag pt ON i.real_port_num = pt.port_num and pt.tag_name = 'PRFTCNTR'               
LEFT OUTER JOIN account clr ON tif.clr_brkr_num = clr.acct_num              
LEFT OUTER JOIN account brkr ON i.brkr_num = brkr.acct_num,              
account b              
where i.item_type in ( 'F' ,'X','E')              
and t.inhouse_ind = 'N'              
and ( (to1.order_type_code in ('EXCHGOPT')               
 AND tid.what_if_ind = 'N'                 
 AND tid.is_equiv_ind = 'N'                 
 AND tid.real_synth_ind = 'R'                 
 AND tid.dist_type = 'D'   )              
     )              
and t.trade_num = i.trade_num               
and i.booking_comp_num = b.acct_num               
and clr.acct_short_name not in ('VARTEST EXC BRK','VARTEST CPTY','INTERNAL')              
and tp.last_trade_date >=CONVERT(DATETIME, CONVERT(VARCHAR, Getdate(), 103), 103)                
and risk_mkt_code not in ('CAPESIZE')              
and isnull(contr_qty,0)<>0 and  isnull(tif.avg_fill_price,0)<>0               
and contr_date<convert(char,getdate(),101)              
and contr_date>=@ContrDate              
and clr.acct_short_name not in ('B82A58','B82A59','B82A60','B82A61','B82A62','B82A63','B82A64','B82B44','B82B45','B82B57',        
'B82A5','B82A58','B82A12','B82A20','B82A21','B82A22','B82A23','B82A24','B82A25')        
              
END              
GO
GRANT EXECUTE ON  [dbo].[mercuria_kiodex_data] TO [next_usr]
GO
