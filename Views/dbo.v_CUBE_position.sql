SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
 CREATE view [dbo].[v_CUBE_position]                      
(trader_init,                           
contr_date,                           
trade_num,                           
trade_key ,                           
counterparty,                           
order_type_code,                           
inhouse_ind,                           
postion_type_desc,                          
trading_entity,                          
book,                          
profit_cntr,                          
real_port_num,                          
dist_num,                          
pos_num,                          
cmdty_group,                           
cmdty_code,                          
cmdty_short_name,                           
mkt_code,                           
mkt_short_name,                          
commkt_key,                           
trading_prd,                          
pos_type,                           
position_p_s_ind,                          
pos_qty_uom_code,                           
primary_pos_qty,                          
secondary_qty_uom_code,                           
secondary_pos_qty,                          
is_equiv_ind ,                          
contract_p_s_ind,                          
contract_qty_uom_code ,                           
contract_qty,                           
mtm_price_source_code,                           
is_hedge_ind,                          
GridPositionMonth,                          
GridPositionQtr ,                          
GridPositionYear,                          
trading_prd_desc,                          
last_issue_date,                          
last_trade_date,                          
trade_mod_date,                           
trade_creation_date,                          
trans_id ,                      
BookEntityNum,                        
--LastUpdatedDate,                      
PricingRiskDate,                      
Product                      
)                          
                          
as                          
                          
                          
                          
select distinct t.trader_init, contr_date, tid.trade_num,                           
 convert(varchar,tid.trade_num)+'/'+convert(varchar,tid.order_num)+'/'+convert(varchar,tid.item_num) ,                           
 CASE  when inhouse_ind='Y' then convert(varchar, t.port_num) ELSE isnull(a1.acct_short_name, t.port_num) END ,                           
 order_type_code,                           
 inhouse_ind,                           
 (CASE  when pos_type='I' then 'Inv'                          
  when pos_type='F' then 'Fut'                          
  when pos_type='S' then 'Synth'                          
  when pos_type='P' then 'Phys'                          
  when pos_type='Q' and option_type='S' then 'Swap Form'                          
  when pos_type='Q' and option_type is null then 'Trade Form'                          
  when pos_type='M' then 'MTM Form'                
  ELSE pos_type                          
 END) +''+(CASE WHEN is_hedge_ind='Y' then ' Hedge' else ' Prim' END) +''+(CASE WHEN p.is_equiv_ind='Y' then ' Equiv' else '' END),                          
 bookingcomp AS TradingEntity,pt.group_code AS PortGroup,pt.profit_center_code as ProfitCntr,                          
 tid.real_port_num,tid.dist_num,p.pos_num,parent_cmdty_code AS CmdtyGroup, cm1.cmdty_code,c1.cmdty_short_name, m1.mkt_code,                           
 m1.mkt_short_name,p.commkt_key,                   
 case when parent_cmdty_code='FOREXGRP' then 'FORWARD' else tp.trading_prd end,                  
 p.pos_type,                           
 tid.p_s_ind ,  isnull(tid.qty_uom_code_conv_to,tid.qty_uom_code) 'PrimaryQtyUOM',                           
 CASE when tid.p_s_ind='P' then 1 else -1 end *  (dist_qty-alloc_qty)*    isnull(tid.qty_uom_conv_rate,1)                      
'PrimaryPosQty',                          
                     
 CASE WHEN tid.sec_qty_uom_code=tid.qty_uom_code_conv_to then tid.qty_uom_code  else  tid.sec_qty_uom_code end 'secondary_qty_uom_code',                            
 CASE when tid.p_s_ind='P' then 1 else -1 end *isnull((dist_qty-alloc_qty)*                       
  (CASE WHEN tid.sec_qty_uom_code=tid.qty_uom_code_conv_to then 1 else isnull(tid.qty_uom_conv_rate,1)*isnull(tid.sec_conversion_factor,1) end ) ,0) 'SecondaryPosQty'    ,                      
                      
 p.is_equiv_ind ,ti.p_s_ind 'contract_p_s_ind',ti.contr_qty_uom_code , case when ti.p_s_ind='S' then ti.contr_qty *-1 else ti.contr_qty  end 'contract_qty',                           
 cm1.mtm_price_source_code,                           
 p.is_hedge_ind,                     
 substring(datename(mm,tp.last_issue_date),1,3) ,                          
 'Q'+convert(char,datename(q,tp.last_issue_date)) ,                          
 datename(yyyy,tp.last_issue_date) ,                          
 case when parent_cmdty_code='FOREXGRP' then 'FORWARD' else tp.trading_prd_desc end,                          
 tp.last_issue_date,                          
 tp.last_trade_date,                          
 trade_mod_date,                           
 t.creation_date, p.trans_id , port.trading_entity_num,                      
 isnull(quote_end_date,last_issue_date) 'PriceRiskDate',                      
 CASE WHEN to1.order_type_code in ('SWAP','SWAPFLT') and t.acct_num in (1388,1397,6470,2543) then isnull(ti.idms_acct_alloc,cmnt.tiny_cmnt) else NULL end 'Product'                      
 FROM  trade_item ti with (nolock)                      
 LEFT OUTER JOIN comment cmnt with (nolock) ON ti.cmnt_num=cmnt.cmnt_num                      
 , trade_order to1, trade t                          
 LEFT OUTER JOIN account a1 with (nolock)ON a1.acct_num=t.acct_num                            
 ,commodity c1, commodity_market cm1,market m1,                          
 dbo.position AS p  with (nolock)                        
 LEFT OUTER JOIN portfolio port with (nolock) ON p.real_port_num=port.port_num                      
 LEFT OUTER JOIN dbo.commodity_group AS cg ON p.cmdty_code=cg.cmdty_code and cmdty_group_type_code='POSITION'                          
 LEFT OUTER JOIN  dbo.trading_period  AS tp with (nolock) ON p.commkt_key = tp.commkt_key and p.trading_prd = tp.trading_prd                             
 LEFT OUTER JOIN  dbo.jms_reports as pt with (nolock)  ON pt.port_num=p.real_port_num                           
 LEFT OUTER JOIN  (select bc.acct_short_name AS bookingcomp, te1.port_num from dbo.portfolio_tag AS te1, account bc where te1.tag_name='BOOKCOMP' and bc.acct_num=convert(int,te1.tag_value))                           
  te ON te.port_num=p.real_port_num                           
 ,trade_item_dist tid with (nolock)                      
 LEFT OUTER JOIN accumulation acc with (nolock) ON tid.trade_num=acc.trade_num and tid.order_num=acc.order_num and tid.item_num=acc.item_num and tid.accum_num=acc.accum_num                       
 WHERE p.commkt_key=cm1.commkt_key                          
 and cm1.cmdty_code=c1.cmdty_code                          
 and cm1.mkt_code=m1.mkt_code                          
 and p.pos_num=tid.pos_num                          
and p.pos_type not in ('W','X','O')                           
--and last_trade_date>=dateadd(dd,-10,getdate())                        
--and tid.real_port_num in (select port_num from #children)                          
and tid.trade_num=to1.trade_num                          
and tid.order_num=to1.order_num                          
and tid.trade_num=t.trade_num                          
and tid.trade_num=ti.trade_num                          
and tid.order_num=ti.order_num                          
and tid.item_num=ti.item_num                          
and round(dist_qty-alloc_qty,2)<>0                           
and ((p.pos_type='F' and tp.last_trade_date>=dateadd(dd,-10,getdate())  ) OR p.pos_type<>'F')                          
and p.pos_type<>'I'                          
and p.pos_num<>277014                 
and p.pos_status not in ('YNN','NNN')            
                          
union                          
                          
                          
select distinct i.trader_init, contr_date, i.trade_num,                           
 convert(varchar,i.trade_num)+'/'+convert(varchar,i.order_num)+'/'+convert(varchar,i.item_num)+'/'+convert(varchar,i.inv_num) ,                           
 i.acct_short_name ,                           
 'STORAGE',                           
 'N',                           
 (CASE  when pos_type='I' then 'Inv'                          
  ELSE pos_type                          
 END) +''+(CASE WHEN is_hedge_ind='Y' then ' Hedge' else ' Prim' END) ,                          
 bookingcomp AS TradingEntity,pt.group_code AS PortGroup,pt.profit_center_code as ProfitCntr,                          
 p.real_port_num,i.inv_num,p.pos_num,parent_cmdty_code AS CmdtyGroup, cm1.cmdty_code,c1.cmdty_short_name, m1.mkt_code,                           
 m1.mkt_short_name,p.commkt_key, p.trading_prd,p.pos_type, 'P'as p_s_ind ,                          
 p.qty_uom_code, (p.long_qty- p.short_qty),                        
 p.sec_pos_uom_code, (p.sec_long_qty- p.sec_short_qty),                        
/* i.inv_qty_uom_code,                          
  case when p1.open_close_ind in ('R','C') then                           
   case when i.open_close_ind in ('O')                           
   then isnull(i.inv_open_prd_proj_qty,0)+isnull(i.inv_open_prd_actual_qty,0)+isnull(i.inv_adj_qty,0)+isnull(i.inv_cnfrmd_qty,0)                          
  end                           
  else                           
        (isnull(i.inv_adj_qty,0)+isnull(i.inv_cnfrmd_qty,0))                           
  end  ,                          
 i.inv_sec_qty_uom_code,                           
 case when p1.open_close_ind in ('R','C') then                            
  case when i.open_close_ind in ('O')                           
  then (isnull(i.inv_open_prd_proj_sec_qty,0)+isnull(i.inv_open_prd_actual_sec_qty,0)) + (isnull(i.inv_cnfrmd_sec_qty,0)+isnull(i.inv_adj_sec_qty,0))                           
 end                           
 else (isnull(i.inv_adj_sec_qty,0)+isnull(i.inv_cnfrmd_sec_qty,0))                           
 end  , */                         
 p.is_equiv_ind ,'P' 'contract_p_s_ind',p.qty_uom_code,  p.long_qty-short_qty 'contract_qty',                           
 cm1.mtm_price_source_code,                           
 p.is_hedge_ind,                          
 substring(datename(mm,tp.last_issue_date),1,3) ,                          
 'Q'+convert(char,datename(q,tp.last_issue_date)) ,                          
 datename(yyyy,tp.last_issue_date) ,                          
 tp.trading_prd_desc,                          
 tp.last_issue_date,tp.last_trade_date,                          
 creation_date,                           
 i.creation_date, p.trans_id   , port.trading_entity_num,                   
 tp.last_issue_date 'PriceRiskDate',                      
 NULL 'Product'                      
 FROM commodity c1, commodity_market cm1,market m1,                          
 dbo.position AS p with (nolock)                          
 LEFT OUTER JOIN portfolio port with (nolock) ON p.real_port_num=port.port_num                      
 LEFT OUTER JOIN dbo.commodity_group AS cg ON p.cmdty_code=cg.cmdty_code and cmdty_group_type_code='POSITION'                          
 LEFT OUTER JOIN  dbo.trading_period  AS tp with (nolock) ON p.commkt_key = tp.commkt_key and p.trading_prd = tp.trading_prd                             
 LEFT OUTER JOIN  dbo.jms_reports as pt with (nolock) ON pt.port_num=p.real_port_num                           
-- LEFT OUTER JOIN icts_transaction icts ON icts.trans_id=p.trans_id                      
 LEFT OUTER JOIN  (select bc.acct_short_name AS bookingcomp, te1.port_num from dbo.portfolio_tag AS te1, account bc where te1.tag_name='BOOKCOMP' and bc.acct_num=convert(int,te1.tag_value))                           
  te ON te.port_num=p.real_port_num   ,                        
                
(                        
 SELECT MAX(ti.trade_num) trade_num, MAX(ti.order_num) order_num, max(ti.item_num) item_num,max(inv_num) inv_num,max(trader_init) trader_init, max(contr_date) contr_date, max(a1.acct_short_name) acct_short_name, pos_num, max(creation_date) creation_date 
  
     
      
       
           
            
              
 FROM trade_item ti with (nolock),trade t          
 LEFT OUTER JOIN account a1 ON a1.acct_num=t.acct_num  ,                          
 inventory i1 with (nolock)                         
 WHERE ti.trade_num=i1.trade_num                          
 and ti.order_num=i1.order_num                          
 and ti.item_num =i1.sale_item_num                          
 and ti.trade_num=t.trade_num                          
group by pos_num             
) i                        
                        
 WHERE i.pos_num=p.pos_num                          
 and p.commkt_key=cm1.commkt_key                          
 and cm1.cmdty_code=c1.cmdty_code                          
 and cm1.mkt_code=m1.mkt_code                          
 and p.pos_type ='I'                           
 and (round(isnull(long_qty,0.0) - isnull(short_qty,0.0) ,2) )<>0                   
 and p.pos_status not in ('YNN','NNN')                     
          
union          
          
          
select distinct 'SU', '01/01/2013', 
case when CHARINDEX('.', key1) <> 0 then 8000000+(STUFF(key1,CHARINDEX('.', key1),1,'')) else 7000000+key1 end,
convert(varchar,case when CHARINDEX('.', key1) <> 0 then 8000000+(STUFF(key1,CHARINDEX('.', key1),1,'')) else 7000000+key1 end)
+'/'+convert(varchar,case when CHARINDEX('.', key1) <> 0 then (STUFF(key1,CHARINDEX('.', key1),1,'')) else key1 end )+
'/'+convert(varchar,case when CHARINDEX('.', key1) <> 0 then (STUFF(key1,CHARINDEX('.', key1),1,'')) else key1 end),                           
 NULL,                           
 case when dist_type='B' then 'BARGE'           
   when dist_type='V' then 'VESSEL'          
   end order_type_code,                           
 'N',                           
 (CASE  when pos_type='B' then 'Barge'                          
  when pos_type='V' then 'Vessel'                          
  ELSE pos_type                          
 END) +''+(CASE WHEN is_hedge_ind='Y' then ' Hedge' else ' Prim' END) +''+(CASE WHEN p.is_equiv_ind='Y' then ' Equiv' else '' END),                          
 bookingcomp AS TradingEntity,pt.group_code AS PortGroup,pt.profit_center_code as ProfitCntr,                          
 tid.real_port_num,tid.oid,p.pos_num,parent_cmdty_code AS CmdtyGroup, cm1.cmdty_code,c1.cmdty_short_name, m1.mkt_code,                           
 m1.mkt_short_name,p.commkt_key,                   
 case when parent_cmdty_code='FOREXGRP' then 'FORWARD' else tp.trading_prd end,                  
 p.pos_type,                           
 p_s_ind ,  isnull(tid.qty_uom_code,p.qty_uom_code) 'PrimaryQtyUOM',                           
 CASE when p_s_ind='P'  then 1 else -1 end *  (dist_qty-alloc_qty) 'PrimaryPosQty',                          
 p.sec_pos_uom_code 'secondary_qty_uom_code',                            
 CASE when p_s_ind='P' then 1 else -1 end *  (dist_qty-alloc_qty)*uom_factor  'SecondaryPosQty'    ,                      
 p.is_equiv_ind ,          
 p_s_ind 'contract_p_s_ind',            
 tid.qty_uom_code,           
 CASE when p_s_ind='P' then 1 else -1 end *  (dist_qty) 'contract_qty',                           
 cm1.mtm_price_source_code,                           
 p.is_hedge_ind,                          
 substring(datename(mm,tp.last_issue_date),1,3) ,                          
 'Q'+convert(char,datename(q,tp.last_issue_date)) ,                          
 datename(yyyy,tp.last_issue_date) ,                          
 case when parent_cmdty_code='FOREXGRP' then 'FORWARD' else tp.trading_prd_desc end,                          
 tp.last_issue_date,                          
 tp.last_trade_date,                          
 NULL,                           
 '01/01/2013', p.trans_id , port.trading_entity_num,                      
 tp.last_issue_date 'PriceRiskDate',                      
 NULL 'Product'                      
 FROM  commodity c1, commodity_market cm1,market m1,                          
 dbo.position AS p  with (nolock)       
 CROSS APPLY udf_METgetUomConversion (p.qty_uom_code, p.sec_pos_uom_code,NULL,NULL,p.cmdty_code )                           
 LEFT OUTER JOIN portfolio port with (nolock) ON p.real_port_num=port.port_num     
 LEFT OUTER JOIN dbo.commodity_group AS cg ON p.cmdty_code=cg.cmdty_code and cmdty_group_type_code='POSITION'                          
 LEFT OUTER JOIN  dbo.trading_period  AS tp with (nolock) ON p.commkt_key = tp.commkt_key and p.trading_prd = tp.trading_prd                             
 LEFT OUTER JOIN  dbo.jms_reports as pt with (nolock)  ON pt.port_num=p.real_port_num                           
 LEFT OUTER JOIN  (select bc.acct_short_name AS bookingcomp, te1.port_num from dbo.portfolio_tag AS te1, account bc where te1.tag_name='BOOKCOMP' and bc.acct_num=convert(int,te1.tag_value))                           
  te ON te.port_num=p.real_port_num                           
 ,vessel_dist tid with (nolock)                      
 WHERE p.commkt_key=cm1.commkt_key                          
 and cm1.cmdty_code=c1.cmdty_code                          
 and cm1.mkt_code=m1.mkt_code                          
 and p.pos_num=tid.pos_num                          
and p.pos_type not in ('W','X','O')                           
--and last_trade_date>=dateadd(dd,-10,getdate())                        
--and tid.real_port_num in (select port_num from #children)                          
and round(dist_qty-alloc_qty,2)<>0                           
and ((p.pos_type='F' and tp.last_trade_date>=dateadd(dd,-10,getdate())  ) OR p.pos_type<>'F')                          
and p.pos_type<>'I'                          
and p.pos_num<>277014                 
and p.pos_status not in ('YNN','NNN')       

GO
GRANT SELECT ON  [dbo].[v_CUBE_position] TO [next_usr]
GO
