SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_MDS_internal_trade_phys]  
(  
contr_date,   
trade_num,  
order_num,  
item_num,  
p_s_ind,
port_num,  
alloc_num,  
alloc_item_num,  
opp_trade_num,  
opp_order_num,  
opp_item_num,  
opp_port_num,  
opp_alloc_num,  
opp_alloc_item_num  
)  
AS  
  
SELECT   
purchase.contr_date,  
PurchaseTrade,  
PurchaseOrder,  
PurchaseItem,  
p_s_ind,
PurchasePortNum,  
PurchaseAlloc,  
PurchaseAI,  
SaleTrade,  
SaleOrder,  
SaleItem,  
SalePortNum,  
SaleAlloc,  
SaleAI  
FROM  
  
  (Select pt.trader_init,  
    pt.contr_date,  
    pti.real_port_num 'PurchasePortNum',  
    pti.trade_num as 'PurchaseTrade',  
    pti.order_num  as  'PurchaseOrder',  
    pti.item_num  as  'PurchaseItem', 
    pti.p_s_ind, 
    pai.alloc_num  as  'PurchaseAlloc',  
    pai.alloc_item_num  as 'PurchaseAI',  
    pti.internal_parent_trade_num sale_trade,   
    pti.internal_parent_order_num sale_order,  
    pti.internal_parent_item_num sale_item  
  
      from  
      trade pt  
      inner join trade_item pti with (NOLOCK) on pti.trade_num =pt.trade_num --and pti.p_s_ind='P'  
      inner join  trade_item_wet_phy ptiwp on pti.trade_num =  ptiwp.trade_num  and pti.order_num = ptiwp.order_num and pti.item_num = ptiwp.item_num   
      left outer join allocation_item pai on ptiwp.trade_num = pai.trade_num and   ptiwp.order_num = pai.order_num and ptiwp.item_num = pai.item_num    
        
      where inhouse_ind = 'I'   
      --and contr_date >= '01/01/2013'  
      ) purchase  
      FULL OUTER  JOIN  
      (  
      Select st.trader_init,  
    st.contr_date,  
    sti.real_port_num 'SalePortNum',      
    sti.trade_num as 'SaleTrade',  
    sti.order_num  as  'SaleOrder',  
    sti.item_num  as  'SaleItem',  
    sai.alloc_num  as  'SaleAlloc',  
    sai.alloc_item_num  as 'SaleAI',  
    sti.internal_parent_trade_num purch_trade,   
    sti.internal_parent_order_num purch_order,  
    sti.internal_parent_item_num purch_item  
  
      from  
      trade st  
      inner  join trade_item sti with (NOLOCK) on sti.trade_num =st.trade_num --and sti.p_s_ind='S'  
      inner join  trade_item_wet_phy stiwp on sti.trade_num =  stiwp.trade_num  and sti.order_num = stiwp.order_num and sti.item_num = stiwp.item_num   
   left outer join allocation_item sai on stiwp.trade_num = sai.trade_num and      stiwp.order_num =sai.order_num and stiwp.item_num = sai.item_num    
      where inhouse_ind = 'I'   
      --and contr_date >= '01/01/2013'  
      ) sale  
        
ON  purchase.contr_date=sale.contr_date   
and (    (purchase.PurchaseTrade=sale.purch_trade   
      and purchase.PurchaseOrder=sale.purch_order   
     and purchase.PurchaseItem=sale.purch_item   
    )  
  
  OR   
  (sale.SaleTrade=purchase.sale_trade  
  and sale.SaleOrder=purchase.sale_order   
  and sale.SaleItem=purchase.sale_item   
  )  
)  
  
GO
GRANT SELECT ON  [dbo].[v_MDS_internal_trade_phys] TO [next_usr]
GO
