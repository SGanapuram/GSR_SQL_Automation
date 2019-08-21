SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
   
CREATE proc [dbo].[usp_get_mkt_price_for_positions]  
(  
 @top_port_num int  
)   
as  
  
 create table #children   
 (  
  port_num int,   
  port_type char(2)  
 )  
  
 exec port_children @top_portfolio=@top_port_num, @port_type='R' ,@show_port_num_ind=0
  
  
 create table #allPos   
  ( posNum   int,   
   mtm_mkt_price  float,   
   mtm_asof_date  datetime,   
   commktKey   int,   
   priceSourceCode char(8),   
   tradingPrd   varchar(40)  
  )  
  
 insert into #allPos  
 select pos_num, null, null, pos.commkt_key,cm.mtm_price_source_code, pos.trading_prd  
 from dbo.position pos with(nolock) inner join #children cp on cp.port_num=pos.real_port_num  
 inner join commodity_market cm on cm.commkt_key=pos.commkt_key  
  
  
 update #allPos   
 set mtm_mkt_price = pmtm.mtm_mkt_price,   
     mtm_asof_date=pmtm.mtm_asof_date  
 from #allPos ap   
 inner join (select pmtm.pos_num, max(pmtm.mtm_asof_date) as max_mtm_asof_date  
    from position_mark_to_market pmtm with(nolock)  
    inner join #allPos apos on apos.posNum = pmtm.pos_num  
    group by pmtm.pos_num) pmax   
   on pmax.pos_num=ap.posNum  
   inner join position_mark_to_market pmtm with(nolock)   
   on pmtm.pos_num =pmax.pos_num and pmtm.mtm_asof_date=pmax.max_mtm_asof_date  
  
 update #allPos   
 set mtm_mkt_price=pr.avg_closed_price,   
     mtm_asof_date=pr.price_quote_date  
 from #allPos ap  
 inner join (select max(pr.price_quote_date) maxQDate, ap.posNum  
 from #allPos ap   
 inner join price pr on pr.commkt_key=ap.commktKey and pr.trading_prd=ap.tradingPrd and pr.price_source_code=ap.priceSourceCode  
 where ap.mtm_mkt_price is null  
 group by ap.posNum) prMax on prMax.posNum=ap.posNum   
 inner join price pr on pr.commkt_key = ap.commktKey and pr.trading_prd=ap.tradingPrd and pr.price_source_code=ap.priceSourceCode  
 and pr.price_quote_date=prMax.maxQDate  
 where ap.mtm_mkt_price is null and ap.posNum=prMax.posNum  
  
 update #allPos set mtm_mkt_price=pr.avg_closed_price, mtm_asof_date=pr.price_quote_date  
 from #allPos ap  
 inner join (select max(pr.price_quote_date) maxQDate, ap.posNum  
 from #allPos ap   
 inner join price pr on pr.commkt_key=ap.commktKey and pr.trading_prd='SPOT' and pr.price_source_code=ap.priceSourceCode  
 where ap.mtm_mkt_price is null  
 group by ap.posNum) prMax on prMax.posNum=ap.posNum   
 inner join price pr on pr.commkt_key = ap.commktKey and pr.trading_prd='SPOT' and pr.price_source_code=ap.priceSourceCode  
 and pr.price_quote_date=prMax.maxQDate  
 where ap.mtm_mkt_price is null and ap.posNum=prMax.posNum  
  
select posNum, mtm_mkt_price from #allPos  
GO
GRANT EXECUTE ON  [dbo].[usp_get_mkt_price_for_positions] TO [next_usr]
GO
