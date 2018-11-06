SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_MDS_get_conc_trade_detail]                
(                
TradeKey,                
TradeNum,                
OrderNum,                
ItemNum,      
ShipmentNum,              
PortNum,        
CostNum,      
TypeCode,               
ValueType,              
DataType,                
DataTypeCode,                
DataTypeDesc,                
Formula,                
PriceValue  ,              
Value              
)                
AS                
--Assay                
SELECT CONVERT(varchar,tis.trade_num)+'/'+CONVERT(varchar,tis.order_num)+'/'+CONVERT(varchar,tis.item_num) 'TradeKey',
tis.trade_num,tis.order_num,tis.item_num, ship.oid,
c.port_num,
c.cost_num,
c.cost_type_code,  'TradePrice',
'ASSAY' DataType ,spec.spec_code DataTypeCode, spec.spec_desc DataTypeDesc ,'' Formula, isnull(aisp.spec_actual_value,tis.spec_typical_val)  DataValue  ,NULL
from trade_item_spec tis         
 INNER JOIN cost c  ON tis.trade_num=c.cost_owner_key6 and tis.order_num = c.cost_owner_key7 and tis.item_num = c.cost_owner_key8                 
 LEFT OUTER JOIN (select trade_num, order_num,item_num,     
     isnull(ais.alloc_num,aies.alloc_num) alloc_num,    
     isnull(ais.alloc_item_num,aies.alloc_item_num) alloc_item_num,    
     isnull(ais.spec_code,aies.spec_code) spec_code ,    
     isnull(ais.spec_actual_value,aies.spec_actual_value) spec_actual_value,  aies.ai_est_actual_num    
      from allocation_item ai    
      LEFT OUTER JOIN ai_est_actual_spec aies ON ai.alloc_num=aies.alloc_num and ai.alloc_item_num=aies.alloc_item_num     
      LEFT OUTER JOIN  allocation_item_spec ais       ON ai.alloc_num=ais.alloc_num and ai.alloc_item_num=ais.alloc_item_num        
      WHERE ai.alloc_num=ais.alloc_num and ai.alloc_item_num=ais.alloc_item_num                   
      )  aisp ON aisp.trade_num=tis.trade_num and aisp.order_num=tis.order_num and aisp.item_num=tis.item_num      
   and c.cost_owner_key1=aisp.alloc_num and c.cost_owner_key2=aisp.alloc_item_num and c.cost_owner_key3=aisp.ai_est_actual_num    
 LEFT OUTER JOIN specification spec ON spec.spec_code=isnull(aisp.spec_code,tis.spec_code)     
  LEFT OUTER JOIN shipment ship ON ship.alloc_num=c.cost_owner_key1    
where exists (select 1 from cost_price_detail cpd where cpd.cost_num=c.cost_num)                
--and c.cost_num = 5037295      
and c.cost_status<>'CLOSED'    
and c.cost_type_code in ('WPP','DPP')     
  
           
union                
--Payable                
SELECT CONVERT(varchar,c.cost_owner_key6)+'/'+CONVERT(varchar,c.cost_owner_key7)+'/'+CONVERT(varchar,c.cost_owner_key8) 'TradeKey',                
c.cost_owner_key6,c.cost_owner_key7,c.cost_owner_key8, ship.oid,  c.port_num, c.cost_num,c.cost_type_code,'TradePrice','PAYABLE' DataType ,              
basis_cmdty_code DataTypeCode,                 
cmdty.cmdty_short_name DataTypeDesc ,                
convert(nvarchar(max),price_quote_string) 'Formula',                
case when isnull(unit_price,1)=0 then 1 else isnull(unit_price,1) end /(case when isnull(price_pcnt_value,1)=0 then 1 else isnull(price_pcnt_value,1) end/100)  DataValue  , isnull(fc.last_computed_value,cp.fb_value)              
from cost c       
  LEFT OUTER JOIN shipment ship ON ship.alloc_num=c.cost_owner_key1    
LEFT OUTER JOIN cost_price_detail cp ON c.cost_num=cp.cost_num                
LEFT OUTER JOIN fb_modular_info fc on cp.formula_num=fc.formula_num and cp.formula_body_num=fc.formula_body_num and pay_deduct_ind='P'                  
LEFT OUTER JOIN commodity cmdty On cmdty.cmdty_code=fc.basis_cmdty_code                
--INNER JOIN formula_component cc on fc.formula_num = cc.formula_num and fc.formula_body_num = cc.formula_body_num and cc.formula_comp_type = 'U'                 
--and cc.formula_comp_name like '%Pct'                 
where basis_cmdty_code not like 'TC%'                
--and c.cost_num=5037295                
and c.cost_status<>'CLOSED'    
and c.cost_type_code in ('WPP','DPP')        
                
union                
--TC                
SELECT CONVERT(varchar,c.cost_owner_key6)+'/'+CONVERT(varchar,c.cost_owner_key7)+'/'+CONVERT(varchar,c.cost_owner_key8) 'TradeKey',                
c.cost_owner_key6,c.cost_owner_key7,c.cost_owner_key8, ship.oid,  c.port_num, c.cost_num,c.cost_type_code,'TradePrice','DEDUCTION' DataType ,                
basis_cmdty_code DataTypeCode,                 
cmdty.cmdty_short_name DataTypeDesc ,                
convert(nvarchar(max),price_quote_string) 'Formula',                
-- MERCC-48 fb_value  DataValue  ,
case when isnull(unit_price,1)=0 then 1 else isnull(unit_price,1) end /(case when isnull(price_pcnt_value,1)=0 then 1 else isnull(price_pcnt_value,1) end/100)  DataValue  ,
isnull(fc.last_computed_value,cp.fb_value)              
from cost c                  
  LEFT OUTER JOIN shipment ship ON ship.alloc_num=c.cost_owner_key1    
LEFT OUTER JOIN cost_price_detail cp ON c.cost_num=cp.cost_num                
INNER JOIN fb_modular_info fc on cp.formula_num=fc.formula_num and cp.formula_body_num=fc.formula_body_num and pay_deduct_ind='P'                  
LEFT OUTER JOIN commodity cmdty On cmdty.cmdty_code=fc.basis_cmdty_code                
--LEFT OUTER JOIN formula_component cc on fc.formula_num = cc.formula_num and fc.formula_body_num = cc.formula_body_num and --cc.formula_comp_type = 'U'                 
--and cc.formula_comp_name like '%Pct'                 
where basis_cmdty_code  like 'TC%'                
and c.cost_status<>'CLOSED'    
and c.cost_type_code in ('WPP','DPP')    
---and c.cost_num=4270394                
union                
--Penalty                
              
 select  DISTINCT                
 CONVERT(varchar,c.cost_owner_key6)+'/'+CONVERT(varchar,c.cost_owner_key7)+'/'+CONVERT(varchar,c.cost_owner_key8) 'TradeKey',                
c.cost_owner_key6,c.cost_owner_key7,c.cost_owner_key8,  ship.oid, c.port_num, c.cost_num,c.cost_type_code,'TradePrice','PENALTY' DataType ,                
basis_cmdty_code DataTypeCode,                 
cmdty.cmdty_short_name DataTypeDesc ,                
convert(nvarchar(max),price_quote_string) 'Formula',                
fb_value  DataValue  , isnull(fc.last_computed_value,cp.fb_value)              
from cost c                
  LEFT OUTER JOIN shipment ship ON ship.alloc_num=c.cost_owner_key1    
LEFT OUTER JOIN cost_price_detail cp ON c.cost_num=cp.cost_num                 
INNER JOIN fb_modular_info fc on cp.formula_num=fc.formula_num and cp.formula_body_num=fc.formula_body_num and pay_deduct_ind in ('D'    )              
LEFT OUTER JOIN commodity cmdty On cmdty.cmdty_code=fc.basis_cmdty_code                
--INNER JOIN formula_component cc on fc.formula_num = cc.formula_num and fc.formula_body_num = cc.formula_body_num and --cc.formula_comp_type = 'U'                 
--and cc.formula_comp_name not like '%Pct'                 
---inner join formula_component c2 on fc.formula_num = c2.formula_num and fc.formula_body_num = c2.formula_body_num and c2.formula_comp_type = 'U' and c2.formula_comp_name like '%Penalty'                 
where 1=1  --c.cost_num=4270394            
and c.cost_status<>'CLOSED'    
and c.cost_type_code in ('WPP','DPP')        
              
union              
--Market Payable  & TC & Penalty              
SELECT CONVERT(varchar,ti.trade_num)+'/'+CONVERT(varchar,ti.order_num)+'/'+CONVERT(varchar,ti.item_num) 'TradeKey',                
ti.trade_num,ti.order_num,ti.item_num, NULL ShipmentNum, ti.real_port_num,  ti.trade_num, 'Mkt','MarketPrice',              
case when pay_deduct_ind='D' then 'PENALTY'               
  when pay_deduct_ind='P' and basis_cmdty_code like 'TC%' then 'DEDUCTION'               
  when pay_deduct_ind='P' and basis_cmdty_code not like 'TC%' then 'PAYABLE' end  DataType ,                
basis_cmdty_code DataTypeCode,                 
cmdty.cmdty_short_name DataTypeDesc ,                
convert(nvarchar(max),price_quote_string) 'Formula',  NULL,              
last_computed_value --fb_value  DataValue                
from trade_item ti                  
LEFT OUTER JOIN trade_formula tf ON ti.trade_num=tf.trade_num and ti.order_num=tf.order_num and ti.item_num=tf.item_num and fall_back_ind='M'              
--LEFT OUTER JOIN formula_component fco ON fco.formula_num=tf.formula_num               
INNER JOIN fb_modular_info fc on tf.formula_num=fc.formula_num  and pay_deduct_ind in ('P' ,'D')                 
LEFT OUTER JOIN commodity cmdty On cmdty.cmdty_code=fc.basis_cmdty_code                
--INNER JOIN formula_component cc on fc.formula_num = cc.formula_num and fc.formula_body_num = cc.formula_body_num --and --cc.formula_comp_type = 'U'   --and cc.formula_comp_name like '%Pct'                 
where 1=1-- ti.trade_num=2670190 and ti.order_num=10              
union            
SELECT distinct CONVERT(varchar,ti.trade_num)+'/'+CONVERT(varchar,ti.order_num)+'/'+CONVERT(varchar,ti.item_num) 'TradeKey',                
ti.trade_num,ti.order_num,ti.item_num, NULL ShipmentNum,ti.real_port_num, ti.trade_num,'Mkt','MarketPrice',            
case when pay_deduct_ind='D' then 'PENALTY'               
  when pay_deduct_ind='P' and basis_cmdty_code like 'TC%' then 'DEDUCTION'               
  when pay_deduct_ind='P' and basis_cmdty_code not like 'TC%' then 'PAYABLE' end  DataType ,              
  basis_cmdty_code DataTypeCode,              
cmdty.cmdty_short_name DataTypeDesc ,               
convert(nvarchar(max),price_quote_string) 'Formula',                
pr.avg_closed_price  DataValue  , pr.avg_closed_price*(case when isnull(price_pcnt_value,1)=0 then 1 else isnull(price_pcnt_value,1) end /100)  *case when basis_cmdty_code in ('GOLD','SILVER') then ( 3.11035) else 1 end             
from trade_item ti                  
INNER JOIn accumulation acc ON acc.trade_num=ti.trade_num and acc.order_num=ti.order_num and acc.item_num=ti.item_num            
--LEFT OUTER JOIN cost_price_detail cp ON c.cost_num=cp.cost_num                
INNER JOIN trade_formula tf ON tf.trade_num=ti.trade_num and tf.order_num=ti.order_num and tf.item_num=ti.item_num            
INNER JOIN fb_modular_info fc on acc.formula_num=fc.formula_num --and cp.formula_body_num=fc.formula_body_num and pay_deduct_ind='P'              
--LEFT OUTER JOIN formula_component cc on fc.formula_num = cc.formula_num and fc.formula_body_num = cc.formula_body_num and cc.formula_comp_type = 'U'                 
INNER JOIN v_CUBE_cmdty_mkt_detail cmdty On cmdty.cmdty_code=fc.basis_cmdty_code    and cmdty.mkt_code=fc.risk_mkt_code            
LEFT OUTER JOIN (select commkt_key, price_source_code, trading_prd, max(avg_closed_price)  avg_closed_price            
   from price             
   where price_source_code='INTERNAL'            
   group by commkt_key, price_source_code, trading_prd            
   )            
   pr ON pr.commkt_key=cmdty.commkt_key and pr.price_source_code=cmdty.mtm_price_source_code and pr.trading_prd=fc.risk_trading_prd --and cc.formula_comp_name like '%Pct'                 
where not exists (select 1 from trade_formula tfm where tfm.trade_num=tf.trade_num and tf.order_num=tfm.order_num and tf.item_num=tfm.item_num and  fall_back_ind='M' )            
--and  ti.trade_num=2656993 and ti.order_num=11

GO
GRANT SELECT ON  [dbo].[v_MDS_get_conc_trade_detail] TO [next_usr]
GO
