SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_option_pl] 
( 
   @AsOfDate      datetime = '01/01/1999',  
   @PortNum       int = NULL,  
   @ProfitCntr    varchar(40) = NULL   
) 
AS  
BEGIN   
IF (@AsOfDate ='01/01/1999')  
BEGIN  
 SELECT @AsOfDate=max(pl_asof_date) from v_BI_cob_date  
END  
  
set nocount on                                                                                
declare @my_top_port_num   int                                                                                
declare @smsg            varchar(255)                                                                                
declare @status          int                                                                                
declare @errcode         int                                                                                
declare @asofdate datetime                                                                                
declare @pl_asof_date datetime                                                          
                                                    
                                                          
 set @my_top_port_num=@PortNum                                                                                
                                                                                
 set @status = 0                                                                                
 set @errcode = 0                                                                                
 if @my_top_port_num is null                                                                                
 select @my_top_port_num = 0                                                                                
  
 create table #children                                                                                
 (                                                                                
   port_num int PRIMARY KEY,                                                                                
   port_type char(2),                                                                                
 )                                                                                
                                                                                
                       
  
  
If (isnull(@PortNum,0)<>0)                                                    
BEGIN                                                    
                                                            
 begin try                                                                                    
  exec dbo.usp_get_child_port_nums @my_top_port_num, 1                                                                                
 end try                                                                                
 begin catch                                                                                
  print '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                   
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                                                                        
 end catch                                                                                
END                                  
                                                    
If (isnull(@PortNum,0)=0 and @ProfitCntr is not null)                                  
BEGIN                                                    
                                                            
 begin try                                                           
                                                    
  insert into #children                                                    
  SELECT port_num,'R' from portfolio_tag where tag_name='PRFTCNTR' and tag_value=@ProfitCntr                                              
  and port_num in (select port_num from portfolio where port_type='R')                               
                                                                       
 end try                                                                                
 begin catch                        
  print '=> Failed to execute the ''profit center'' sp due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                       
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                           
 end catch                                                                                
END                                                
                                                             
                                                            
  
CREATE TABLE #option_summary  
(  
order_type_code char(8),  
contr_date datetime,  
trader_init char(3) NULL,  
profit_center nvarchar(50) NULL,  
trade_num int,  
order_num int,  
item_num int,  
dist_num int,  
pos_num int,  
commkt_key int,  
p_s_ind char(2),  
is_equiv_ind char(1),  
spread_comp_ind char(1),  
contr_qty float null,  
contr_qty_uom_code varchar(15) null,  
cmdty_code varchar(15) null,   
mkt_code varchar(15) null,  
underlying_cmdty_code varchar(15) null,  
underlying_mkt_code varchar(15) null,  
trading_prd varchar(15) null,  
put_call_ind char(1) null,  
opt_type char(1) null,  
exp_date datetime null,  
port_num int,  
premium float null,  
premium_uom_code varchar(15) null,  
premium_curr_code varchar(15) null,  
strike float null,  
strike_uom_code varchar(15) null,  
option_price float null,  
underlying_price float null,  
mtm_pl float null,  
total_pl float null  
)  
  
CREATE TABLE #option_greeks  
(  
trade_num int,  
order_num int,  
item_num int,  
dist_num int,  
pos_num int,  
commkt_key int,  
trading_prd varchar(15) null,  
--underlying_price float null,  
implied_vol float null,  
implied_corr float null,  
interest_rate float null,  
delta_per float null,  
gamma_per float null,  
vega_per float null,  
theta_per float null,  
rho float null,  
delta_value float null,  
gamma_value float null,  
vega_value float null,  
theta_value float null,  
--option_price float null  
  
)  
  
  
  
  
insert into #option_summary  
select order_type_code, contr_date,trader_init,pt.tag_value,ti.trade_num,ti.order_num,ti.item_num,  
tid.dist_num ,  
tid.pos_num ,  
tid1.commkt_key,  
ti.p_s_ind,  
tid.is_equiv_ind ,  
'N',  
ti.contr_qty,  
ti.contr_qty_uom_code,  
ti.cmdty_code,  
ti.risk_mkt_code,  
tidcm.cmdty_code,  
tidcm.mkt_code,  
tid1.trading_prd,  
isnull(tioo.put_call_ind,tieo.put_call_ind),  
isnull(tioo.opt_type,tieo.opt_type),  
isnull(tioo.exp_date,tieo.exp_date),  
ti.real_port_num,  
isnull(tioo.premium ,tieo.premium),  
isnull(tioo.premium_uom_code,tieo.premium_uom_code),  
isnull(tioo.premium_curr_code,tieo.premium_curr_code),  
isnull(tioo.strike_price,tieo.strike_price),  
isnull(tioo.strike_price_uom_code,tieo.strike_price_uom_code),null,null,null,null  
from trade t, trade_order to1,  
 trade_item ti  
 LEFT OUTER JOIN trade_item_otc_opt tioo ON    
     ti.trade_num=tioo.trade_num and   
     ti.order_num=tioo.order_num and   
     ti.item_num=tioo.item_num  
 LEFT OUTER JOIN trade_item_exch_opt tieo ON    
     ti.trade_num=tieo.trade_num and   
     ti.order_num=tieo.order_num and   
     ti.item_num=tieo.item_num  
 INNER JOIN trade_item_dist tid ON   
  tid.trade_num=ti.trade_num  
  and tid.order_num=ti.order_num  
  and tid.item_num=ti.item_num  
  and tid.is_equiv_ind='Y'  
 INNER JOIN trade_item_dist tid1 ON  
  tid1.trade_num=ti.trade_num  
  and tid1.order_num=ti.order_num  
  and tid1.item_num=ti.item_num  
  and tid1.is_equiv_ind='N'  
  INNER JOIN commodity_market tidcm ON   
  tidcm.commkt_key=tid.commkt_key  
   
  , portfolio_tag pt  
where t.trade_num=to1.trade_num  
and to1.trade_num=ti.trade_num  
and to1.order_num=ti.order_num  
and pt.port_num=ti.real_port_num  
and pt.tag_name='PRFTCNTR'  
and isnull(tioo.exp_date,tieo.exp_date)>=@AsOfDate   
and tag_value!='VARTEST'  
and not exists (Select 1 from spread_composition sc where sc.spread_cmdty_code=ti.cmdty_code)  
and ti.real_port_num in (Select port_num from #children)  
  
  
insert into #option_summary  
select order_type_code, contr_date,trader_init,pt.tag_value,ti.trade_num,ti.order_num,ti.item_num,  
dist_num ,  
pos_num ,  
tid.commkt_key,  
ti.p_s_ind,  
tid.is_equiv_ind ,  
'Y',  
ti.contr_qty,  
ti.contr_qty_uom_code,  
ti.cmdty_code,  
ti.risk_mkt_code,  
tidcm.cmdty_code,  
tidcm.mkt_code,  
tid.trading_prd,  
isnull(tioo.put_call_ind,tieo.put_call_ind),  
isnull(tioo.opt_type,tieo.opt_type),  
isnull(tioo.exp_date,tieo.exp_date),  
ti.real_port_num,  
isnull(tioo.premium ,tieo.premium),  
isnull(tioo.premium_uom_code,tieo.premium_uom_code),  
isnull(tioo.premium_curr_code,tieo.premium_curr_code),  
isnull(tioo.strike_price,tieo.strike_price),  
isnull(tioo.strike_price_uom_code,tieo.strike_price_uom_code),null, null,null,null  
from trade t, trade_order to1,  
 trade_item ti  
 LEFT OUTER JOIN trade_item_otc_opt tioo ON    
     ti.trade_num=tioo.trade_num and   
     ti.order_num=tioo.order_num and   
     ti.item_num=tioo.item_num  
 LEFT OUTER JOIN trade_item_exch_opt tieo ON    
     ti.trade_num=tieo.trade_num and   
     ti.order_num=tieo.order_num and   
     ti.item_num=tieo.item_num  
 INNER JOIN trade_item_dist tid ON   
  tid.trade_num=ti.trade_num  
  and tid.order_num=ti.order_num  
  and tid.item_num=ti.item_num  
  INNER JOIN commodity_market tidcm ON   
  tidcm.commkt_key=tid.commkt_key  
   , portfolio_tag pt  
where t.trade_num=to1.trade_num  
and to1.trade_num=ti.trade_num  
and to1.order_num=ti.order_num  
and pt.port_num=ti.real_port_num  
and pt.tag_name='PRFTCNTR'  
and isnull(tioo.exp_date,tieo.exp_date)>=@AsOfDate   
and tag_value!='VARTEST'  
and  exists (Select 1 from spread_composition sc where sc.spread_cmdty_code=ti.cmdty_code)  
and ti.real_port_num in (Select port_num from #children)  
  
insert into #option_greeks  
select tid.trade_num ,tid.order_num,tid.item_num,tid.dist_num,o.pos_num,opt.commkt_key,opt.trading_prd,  
tid.volatility * 100 IV,   
NULL ImpCorr,  
pmtm.interest_rate,  
isnull(tid.delta, pmtm.delta), 
isnull(tid.gamma,pmtm.gamma),  
isnull(tid.vega,pmtm.vega),  
pmtm.theta,  
pmtm.interest_rate RHO,  
round(isnull(tid.delta, pmtm.delta)*o.contr_qty* (case when o.p_s_ind='S' then -1 else 1 end),6) 'DeltaValue',  
round(isnull(tid.gamma,pmtm.gamma)*o.contr_qty* (case when o.p_s_ind='S' then -1 else 1 end),6) 'GammaValue',  
round(isnull(tid.vega,pmtm.vega)*o.contr_qty* (case when o.p_s_ind='S' then -1 else 1 end),6) 'VegaValue',  
round(pmtm.theta*o.contr_qty* (case when o.p_s_ind='S' then -1 else 1 end),6)  'ThetaValue'  
From tid_mark_to_market tid  
INNER JOIN trade_item_dist opt ON opt.trade_num=tid.trade_num and opt.order_num=tid.order_num and opt.item_num=tid.item_num and is_equiv_ind='N'  
LEFT OUTER JOIN  position_mark_to_market pmtm WITH (NOLOCK)   ON pmtm.pos_num=opt.pos_num and pmtm.mtm_asof_date=@AsOfDate,   
#option_summary o  
where tid.dist_num=o.dist_num  
and tid.mtm_pl_asof_date=@AsOfDate  
--and tid.trade_num=1954649  



  
update ti  
SET mtm_pl =pl.mtm_pl,  
total_pl=pl.total_pl  
--SELECT *   
from #option_summary ti  
      INNER JOIN (SELECT real_port_num,pl_primary_owner_key1,pl_primary_owner_key2,pl_primary_owner_key3,  
     sum(case when pl_owner_sub_code not in ('OBC','ADDLTI') then pl_amt else 0 end) mtm_pl,  
     sum(pl_amt ) total_pl  
     FROM pl_history pl WITH (NOLOCK)   
     WHERE  pl_asof_date =@AsOfDate  
     group by real_port_num,pl_primary_owner_key1,pl_primary_owner_key2,pl_primary_owner_key3  
     )  pl ON  
            ti.trade_num = pl.pl_primary_owner_key1 and   
            ti.order_num = pl.pl_primary_owner_key2 and   
            ti.item_num = pl.pl_primary_owner_key3   
WHERE ((is_equiv_ind='Y' and spread_comp_ind='N') OR (is_equiv_ind='N' and spread_comp_ind='Y') )  
              
            --and ti.trade_num=1979649  
       --and ti.port_num = pl.real_port_num    
  
  
  
  
  
update o  
set option_price=opr.avg_closed_price  
from #option_summary o,option_price opr WITH (NOLOCK)  
WHERE opr.trading_prd=o.trading_prd     
and opr.opt_strike_price = o.strike   
and opr.price_source_code='EXCHANGE'   
and opr.put_call_ind = o.put_call_ind    
and opr.opt_price_quote_date =@AsOfDate  
and opr.commkt_key=o.commkt_key   
and opr.avg_closed_price is not null  
  
update o  
set underlying_price=pr.avg_closed_price  
from #option_summary o, price pr  WITH (NOLOCK), commodity_market cm1  
WHERE underlying_cmdty_code=cm1.cmdty_code  
and underlying_mkt_code=cm1.mkt_code  
and pr.commkt_key=cm1.commkt_key   
and pr.trading_prd=o.trading_prd   
and pr.price_source_code=cm1.mtm_price_source_code   
and pr.price_quote_date =@AsOfDate   
  
  
SELECT distinct os.order_type_code OrderTypeCode,  
contr_date 'ContractDate',  
os.trader_init Trader,  
os.profit_center ProfitCenter,  
convert(varchar,os.trade_num)+'/'+convert(varchar,os.order_num)+'/'+convert(varchar,os.item_num) TradeKey,  
@AsOfDate AsOfDate ,  
case when (is_equiv_ind='Y' and spread_comp_ind='N') then 'OPTION'   
     when spread_comp_ind='Y' and is_equiv_ind='Y'  then 'UNDERLYING'  
     when spread_comp_ind='Y' and is_equiv_ind='N'  then 'OPTION'  
end 'UnderlyingInd',  
os.p_s_ind PSInd,  
os.spread_comp_ind 'SpreadCompositionInd',  
contr_qty 'ContractQty',  
contr_qty_uom_code UOM,
os.dist_num DistNum,
os.pos_num PosNum,  
os.cmdty_code Commodity,  
os.mkt_code Market,  
os.underlying_cmdty_code UnderlyingCommodity,  
os.underlying_mkt_code UnderlyingMarket,  
os.trading_prd TradingPrd,  
put_call_ind PutCall,  
opt_type OptionType,  
exp_date ExpiryDate,  
port_num PortNum,  
premium Premium,  
premium_uom_code PremiumUom,  
premium_curr_code PremiumCurr,  
strike StrikePrice,  
strike_uom_code StrikeUom,  
option_price OptionPrice,  
underlying_price UnderlyingPrice,  
implied_vol IV,  
implied_corr 'ImpCorr' ,  
interest_rate InterestRate,  
delta_per DeltaPCT,  
gamma_per GammaPCT,  
vega_per VegaPCT,  
theta_per ThetaPCT,  
rho RHO,  
delta_value DeltaValue,  
gamma_value GammaValue,  
vega_value VegaValue,  
theta_value ThetaValue,  
mtm_pl MTMPL,  
total_pl TotalPL  
  
From #option_summary os,#option_greeks og  
where os.trade_num=og.trade_num  
and os.order_num=og.order_num  
and os.item_num=og.item_num  
and os.dist_num=og.dist_num  
order by TradeKey  
  
  
errexit:                                                                                
   if @errcode > 0                                                                                
      set @status = 2                                                                    
                                                                                   
endofsp:                                                                                
if object_id('tempdb.dbo.#children') is not null                                                                                
   exec('drop table #children')                           
if object_id('tempdb.dbo.#option_summary') is not null                                                                                
   exec('drop table #option_summary')          
if object_id('tempdb.dbo.#option_greeks') is not null                                                                                
   exec('drop table #option_greeks')                                                                                
return @status   
END  
GO
GRANT EXECUTE ON  [dbo].[usp_get_option_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_option_pl', NULL, NULL
GO
