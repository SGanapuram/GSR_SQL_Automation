SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_ags_trade_detail]      
(      
 @portNum int = NULL,      
 @tradeNum int = NULL,      
 @orderNum smallint = NULL,      
 @itemNum smallint =NULL      
)      
as      
      
create table #children                                                                      
(                                                                      
      port_num    int PRIMARY KEY,                                                                      
      port_type   char(2)                                                                    
)          
          
select * into #withPL from v_get_ags_trade_detail where 0=1      
          
if @portNum is not null and @tradeNum is not null          
begin          
          
 exec dbo.usp_get_child_port_nums @portNum, 1          
           
 if @orderNum is null and @itemNum is null          
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where PortNum in ( select port_num from #children )          
       and TradeNum = @tradeNum          
                 
 if @orderNum is not null and @itemNum is null                 
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where PortNum in ( select port_num from #children )          
       and TradeNum = @tradeNum          
    and OrderNum = @orderNum          
              
 if @itemNum is not null and @orderNum is not null               
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where PortNum in ( select port_num from #children )          
       and TradeNum = @tradeNum          
    and OrderNum = @orderNum              
    and ItemNum = @itemNum           
end           
          
else if @portNum is null and @tradeNum is not null          
begin           
          
 if @orderNum is null and @itemNum is null                 
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where TradeNum = @tradeNum          
           
 if @orderNum is not null and @itemNum is null                 
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where TradeNum = @tradeNum          
    and OrderNum = @orderNum          
              
 if @itemNum is not null                 
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where TradeNum = @tradeNum          
    and OrderNum = @orderNum              
    and ItemNum = @itemNum           
end              
          
else if @portNum is not null and @tradeNum is null          
begin           
 exec dbo.usp_get_child_port_nums @portNum, 1          
           
 insert into #withPL          
 select * from v_get_ags_trade_detail           
 where PortNum in ( select port_num from #children )          
end            
          
          
insert into #withPL          
select TradeKey, TradeNum, OrderNum, ItemNum,ShipmentNum, PortNum, CostNum,'PL', '3-SummaryPL', DataType, DataTypeCode,DataTypeDesc,          
RiskPeriod, Qty,QtyUom,Formula, null, Value, null, case ti.p_s_ind when 'P' then Amount else -1*Amount end as Amount , Amt_Curr          
from #withPL w          
inner join trade_item ti on w.TradeNum=ti.trade_num and w.OrderNum=ti.order_num and w.ItemNum=ti.item_num          
where ValueType='2-MarketPrice'          
    
 --select w.Amount, w2.Amount, isnull(w.Amount,0)-isnull(w2.Amount,0), ti.p_s_ind, w.TradeNum, w.OrderNum, w.ItemNum          
update w set Amount = isnull(w.Amount,0)-isnull(w2.Amount,0)          
from #withPL w           
 inner join #withPL w2 on w.TradeNum=w2.TradeNum and w.OrderNum=w2.OrderNum and w.ItemNum=w2.ItemNum and w.DataTypeCode=w2.DataTypeCode          
inner join trade_item ti on w.TradeNum=ti.trade_num and w.OrderNum=ti.order_num and w.ItemNum=ti.item_num          
where w.TypeCode='PL' and ti.p_s_ind='P' and w2.ValueType='1-TradePrice'           
          
--select w.Amount, w2.Amount, isnull(w.Amount,0)+isnull(w2.Amount,0), ti.p_s_ind, w.TradeNum, w.OrderNum, w.ItemNum          
update w set Amount = isnull(w.Amount,0)+isnull(w2.Amount,0)          
from #withPL w           
 inner join #withPL w2 on w.TradeNum=w2.TradeNum and w.OrderNum=w2.OrderNum and w.ItemNum=w2.ItemNum and w.DataTypeCode=w2.DataTypeCode          
inner join trade_item ti on w.TradeNum=ti.trade_num and w.OrderNum=ti.order_num and w.ItemNum=ti.item_num          
where w.TypeCode='PL' and ti.p_s_ind='S' and w2.ValueType='1-TradePrice'           
          
  --select w.Amount, w2.Amount, isnull(w.Amount,0)-isnull(w2.Amount,0), ti.p_s_ind, w.TradeNum, w.OrderNum, w.ItemNum          
update w set Amount = case when isnull(w.Amount,0) > isnull(w2.Amount,0) then  isnull(w.Amount,0)    
                           when isnull(w.Amount,0) <= isnull(w2.Amount,0) then  -1 * isnull(w.Amount,0)     end    
from #withPL w           
 inner join #withPL w2 on w.TradeNum=w2.TradeNum and w.OrderNum=w2.OrderNum and w.ItemNum=w2.ItemNum and w.DataTypeCode=w2.DataTypeCode          
inner join trade_item ti on w.TradeNum=ti.trade_num and w.OrderNum=ti.order_num and w.ItemNum=ti.item_num          
where w.TypeCode='Mkt' and ti.p_s_ind='P' and w2.ValueType='1-TradePrice'           
          
--select w.Amount, w2.Amount, isnull(w.Amount,0)+isnull(w2.Amount,0), ti.p_s_ind, w.TradeNum, w.OrderNum, w.ItemNum          
update w set Amount = case when isnull(w.Amount,0) >= isnull(w2.Amount,0) then  -1 * isnull(w.Amount,0)    
                           when isnull(w.Amount,0) < isnull(w2.Amount,0) then  isnull(w.Amount,0)        end    
from #withPL w           
 inner join #withPL w2 on w.TradeNum=w2.TradeNum and w.OrderNum=w2.OrderNum and w.ItemNum=w2.ItemNum and w.DataTypeCode=w2.DataTypeCode          
inner join trade_item ti on w.TradeNum=ti.trade_num and w.OrderNum=ti.order_num and w.ItemNum=ti.item_num          
where w.TypeCode='Mkt' and ti.p_s_ind='S' and w2.ValueType='1-TradePrice'           
          
select TradeKey,         
  TradeNum,         
  OrderNum,         
  ItemNum,        
  ShipmentNum,         
  PortNum,     CostNum,        
  TypeCode,         
  ValueType,         
  --DataType,     --removed this column as confirmed by Vinny    
  DataTypeCode,        
  DataTypeDesc,          
  
  CASE        WHEN (substring(RiskPeriod,5,2) = '01') THEN 'Jan'  
     WHEN (substring(RiskPeriod,5,2) = '02') THEN 'Feb'  
     WHEN (substring(RiskPeriod,5,2) = '03') THEN 'Mar'  
     WHEN (substring(RiskPeriod,5,2) = '04') THEN 'Apr'  
     WHEN (substring(RiskPeriod,5,2) = '05') THEN 'May'  
     WHEN (substring(RiskPeriod,5,2) = '06') THEN 'Jun'  
     WHEN (substring(RiskPeriod,5,2) = '07') THEN 'Jul'  
     WHEN (substring(RiskPeriod,5,2) = '08') THEN 'Aug'  
     WHEN (substring(RiskPeriod,5,2) = '09') THEN 'Sep'  
     WHEN (substring(RiskPeriod,5,2) = '10') THEN 'Oct'  
     WHEN (substring(RiskPeriod,5,2) = '11') THEN 'Nov'  
     WHEN (substring(RiskPeriod,5,2) = '12') THEN 'Dec'  
  END + ' ' + substring(RiskPeriod,1,4)      as 'RiskPeriod',  
  Qty,  
  QtyUom,        
  Formula,         
  case when Curr = 'USC' then PriceValue/100 else PriceValue end as 'Price',           
  case when Curr = 'USC' then 'USD' else Curr end as PriceCurrency,         
  Amount as 'PL',         
  Amt_Curr as PLCurrency           
from #withPL  

GO
GRANT EXECUTE ON  [dbo].[usp_get_ags_trade_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_ags_trade_detail', NULL, NULL
GO
