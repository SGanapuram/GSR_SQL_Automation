SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[v_CUBE_cmdty_mkt_detail]        
(        
commkt_key,         
cmdty_code,        
cmdty_short_name,         
cmdty_full_name,         
mkt_code,         
mkt_short_name,         
mkt_full_name,      
commkt_name,       
mtm_price_source_code,         
trans_id,          
cmdty_tradeable_ind,         
cmdty_status,         
cmdty_type,         
cmdty_type_code,         
cmdty_type_desc,         
mkt_status,         
prim_uom_code,         
sec_uom_code,         
cmdty_category_code,         
commkt_phy_attr_status,         
commkt_qty_uom_code,          
commkt_price_uom_code,        
sec_price_source_code,        
commkt_fut_attr_status,        
commkt_lot_size,         
commkt_lot_uom_code  ,      
pos_cmdty_group_code,      
pos_cmdty_group_name    ,  
commkt_curr_code  
)        
AS        
select cm.commkt_key, c.cmdty_code,c.cmdty_short_name, c.cmdty_full_name, m.mkt_code, mkt_short_name, mkt_full_name,  cmdty_short_name+'/'+mkt_short_name as commkt_name,       
mtm_price_source_code, cm.trans_id,  cmdty_tradeable_ind, cmdty_status, cmdty_type, ct.cmdty_type_code, ct.cmdty_type_desc, mkt_status,         
prim_uom_code, sec_uom_code, cmdty_category_code,         
commkt_phy_attr_status, isnull(cpa.commkt_qty_uom_code,cfa.commkt_lot_uom_code) commkt_qty_uom_code,           
isnull(cpa.commkt_price_uom_code,cfa.commkt_price_uom_code) commkt_price_uom_code,        
isnull(cfa.sec_price_source_code,cpa.sec_price_source_code) sec_price_source_code,commkt_fut_attr_status,commkt_lot_size, commkt_lot_uom_code  , parent_cmdty_code,parent_cmdty_short_name    ,  
isnull(cpa.commkt_curr_code,cfa.commkt_curr_code) commkt_curr_code  
From commodity_market cm         
JOIN commodity c ON c.cmdty_code=cm.cmdty_code         
JOIN commodity_type ct ON c.cmdty_type=ct.cmdty_type_code        
JOIN market m ON m.mkt_code=cm.mkt_code        
LEFT OUTER JOIN commkt_physical_attr cpa ON cm.commkt_key=cpa.commkt_key        
LEFT OUTER JOIN commkt_future_attr cfa ON cm.commkt_key=cfa.commkt_key        
LEFT OUTER JOIN (select parent_cmdty_code, cg.cmdty_code,prnt.cmdty_short_name 'parent_cmdty_short_name'      
    from commodity_group cg, commodity prnt       
    where cmdty_group_type_code='POSITION'      
    and cg.parent_cmdty_code=prnt.cmdty_code) cg1 on cg1.cmdty_code=c.cmdty_code               
GO
GRANT SELECT ON  [dbo].[v_CUBE_cmdty_mkt_detail] TO [next_usr]
GO
