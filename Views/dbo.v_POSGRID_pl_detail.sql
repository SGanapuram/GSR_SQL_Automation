SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_pl_detail]                                  
(                                  
   pl_record_key,                                  
   pl_asof_date,                                  
   real_port_num,                                  
   cost_num,                                
   pos_num,                            
   pl_owner_code,                              
   pl_owner,                                  
   trade_key,                                  
   trade_cost_type,                                  
   pl_type_code,                                  
   pl_type_desc,                             
   trade_type,                               
   alloc_num,                              
   alloc_item,                            
   pl_amt,                                  
   qty,                                  
   qty_uom,                                  
   cmdty_short_name,                                  
   mkt_short_name,                                
   trading_prd_desc,                              
   trading_prd_date,                             
   pl_mkt_price,                                  
   contr_date,                            
   trade_mod_date,                            
   avg_price,                              
   fx_rate,                                  
   inhouse_ind,  
   pl_realization_date,                                  
   counterparty,                
   price_curr_code,            
   alloc_creation_date,      
   alloc_trans_id,             
   cost_creation_date,          
   cost_trans_id,    
   trade_trans_id,    
   pl_trans_id,  
   creator_init                    
)                                  
as                                 
select  
   pl_record_key,                            
   pl.pl_asof_date ,                             
   pl.real_port_num 'PortfolioNum',                                
   case when pl_owner_sub_code is null then null 
        when pl_owner_code in ('I', 'P') then null 
        else pl_record_key 
   end as 'COST NUMBER',                            
   pl.pos_num,  
   pl_owner_code ,                          
   case when pl.pl_owner_code = 'C' then 'Cost'                             
        when pl_owner_code in ('I', 'P') then 'Inventory Position'                             
        when pl.pl_owner_code = 'T' then 'Trade Value/MTM' 
        else pl_owner_code 
   end 'PL_Owner',                            
   case when pl_owner_sub_code = 'ADDLP' then convert (varchar, pl_record_key)                             
        else convert(varchar, pl.pl_secondary_owner_key1) + '/' + 
                 convert(varchar, pl.pl_secondary_owner_key2) + '/' + 
                    convert(varchar, pl.pl_secondary_owner_key3) 
   end 'TradeKey',                            
   case when pl_owner_sub_code in ('WPP','W','F','PR','PO','SWAP','F','CPP', 'CPR') then 'TRADE'                             
        when pl_owner_sub_code in ('WS', 'ADDLP', 'WS', 'ADDLAI', 'ADDLA', 'ADDLTI','SPP') then 'ADDITIONAL COSTS'                             
        when pl_owner_sub_code is null then 'INVENTORY'                             
        when pl_owner_sub_code in ('Inventory Position', 'I', 'D') then 'INVENTORY'                          
   end 'TradeCostType',                            
   pl_type,                                          
   case when pl_owner_sub_code in ('CPP', 'CPR') then 'CURRENCY'         
        when pl_owner_sub_code is null then 'INVENTORY_POSITION'                              
        when pl_owner_sub_code = 'D' then 'INVENTORY_DRAWS'                             
        when pl_owner_sub_code = 'B' then 'INVENTORY_BUILD'          
        when pl_owner_sub_code = 'W' then 'MARKET_VALUE'                             
        when pl_owner_sub_code = 'SWAP' then 'MTMVALUE'                             
        when pl_owner_sub_code = 'PO' then 'PROVISIONAL OFFSET'                            
        when pl_owner_sub_code = 'PR' then 'PROVISIONAL'                  
        when pl_owner_sub_code in ('F', 'X') and pl_type = 'U' then 'MARKET_VALUE'          
        when pl_owner_sub_code in ('F', 'X') and pl_type = 'R' then 'TRADE_VALUE'              
        when pl_owner_sub_code in ('F', 'X') and pl_type = 'C' then 'TRADE_COST'                
        when pl_owner_sub_code ='NO' then 'NETOUT'           
        when pl_owner_sub_code in ('ADDLA', 'ADDLAA','ADDLAI', 'ADDLP','ADDLSWAP', 'ADDLTI', 
                                   'BC', 'FBC', 'JV', 'MEMO', 'OBC', 'PS', 'PTS', 'SAC', 'SPP', 
                                   'STC', 'SWBC', 'TAC', 'TPP', 'WAP', 'WO', 'WS') then 'SERVICES'                           
        when pl_owner_sub_code in ('BO','BOAI','BPP','E','O','OPP','OTC','WPP') then 'TRADE_VALUE'                
        when pl_owner_sub_code in ('C','NO') then 'TRADE_COST'        
        when pl_owner_sub_code in ('Inventory Position', 'I') then 'INVENTORY'        
        else pl_owner_sub_code 
    end 'PLTypeDesc',                          
    case when pl_owner_code in ('I', 'P') then 'INVENTORY'      
         else isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP'
                                                     when 'SWAPFLT' then 'SWAP' 
                                                     else tor.order_type_code 
                            end, t.trade_status_code), 'OTHER') 
    end as order_type_code,                                   
    case when pl_owner_sub_code = 'D' then pl_primary_owner_key1                             
         when pl_owner_sub_code = 'WPP' and 
              c.cost_owner_code != 'TI' then cost_owner_key1 
         else null 
    end as AllocationNum,                            
    case when pl_owner_sub_code = 'D' then pl_primary_owner_key2                             
         when pl_owner_sub_code = 'WPP' and 
              c.cost_owner_code != 'TI' then cost_owner_key2 
         else null 
    end as AllocationITEM,                                    
    pl_amt 'PLAmt',                            
    case when pl_record_qty is null and 
              pl_owner_sub_code is null 
            then pos.long_qty - short_qty                   
         when pl_record_qty is null and 
              pl_owner_sub_code is not null                   
            then case when ti.p_s_ind = 'S' then -1 
                      else 1 
                 end * ti.contr_qty 
         else pl_record_qty 
    end as Quantity,                            
    case when pl_record_qty_uom_code is null and 
              pl_owner_sub_code is null 
            then pos.qty_uom_code                            
         when pl_record_qty_uom_code is null and 
              pl_owner_sub_code is not null 
            then ti.contr_qty_uom_code                            
         when pl_owner_sub_code in ('CPP', 'CPR') 
            then cost_price_curr_code                            
         else 
            pl_record_qty_uom_code 
    end as QTY_UOM,                            
    case when pl_owner_sub_code = 'SPP'
            then 'STORAGE'                   
         when pl_owner_sub_code in ('WS', 'ADDLP', 'ADDLTI', 'ADDLAI', 'ADDLA', 'CPP', 'CPR')                   
            then c.cost_code 
         else cmdty.cmdty_short_name 
    end as Commodity,                            
    mkt.mkt_short_name as Market,                            
    tp.trading_prd_desc as TradingPrd,                            
    tp.last_issue_date,                            
    pl.pl_mkt_price,                            
    t.contr_date as ContractDate,                            
    t.trade_mod_date as TradeModDate,                            
    case when pl_owner_sub_code in ('P', 'I') then pos.avg_purch_price 
         else ti.avg_price 
    end 'avg_price',                            
    case when currency_fx_rate is null then 1 
         else currency_fx_rate 
    end as FX_RATE,        
    inhouse_ind,                    
    pl_realization_date,                            
    case when pl.pl_owner_code = 'C' then a1.acct_short_name                   
         when t.inhouse_ind = 'I' then 'INTERNAL-'+++ '-' + convert(varchar, t.port_num)                   
    end as Counterparty,                          
    isnull(ti.price_curr_code, c.cost_price_curr_code) price_curr_code,            
    alloc.creation_date as alloc_creation_date,              
    alloc.trans_id,             
    c.creation_date as cost_creation_date,     
    c.trans_id,    
    t.trans_id,    
    pl.trans_id,  
    case when c.cost_prim_sec_ind = 'S' then c.creator_init           
         when cost_owner_code in ('A', 'AA', 'AI') and 
              cost_prim_sec_ind = 'P' then alloc.sch_init          
         when cost_owner_code in ('TI') and 
              cost_prim_sec_ind = 'P' then t.creator_init          
    end 'creator_init'          
from dbo.v_POSGRID_pl_history pl WITH (NOLOCK)    
        left outer join dbo.position pos WITH (NOLOCK) 
           on pl.pos_num = pos.pos_num                            
        left outer join dbo.commodity cmdty WITH (NOLOCK) 
           on cmdty.cmdty_code = pos.cmdty_code                            
        left outer join dbo.market mkt WITH (NOLOCK) 
           on mkt.mkt_code = pos.mkt_code                            
        left outer join trading_period tp WITH (NOLOCK) 
           on pos.commkt_key = tp.commkt_key and 
              tp.trading_prd = pos.trading_prd                             
        left outer join dbo.trade_item ti 
           on ti.trade_num = pl.pl_secondary_owner_key1 and 
              ti.order_num = pl.pl_secondary_owner_key2 and 
              ti.item_num = pl.pl_secondary_owner_key3 and 
              ti.real_port_num = pl.real_port_num                            
        left outer join dbo.trade_order tor 
           on tor.trade_num = pl.pl_secondary_owner_key1 and 
              tor.order_num = pl.pl_secondary_owner_key2                 
        left outer join dbo.trade t 
           on t.trade_num = ti.trade_num                            
        left outer join dbo.cost c WITH (NOLOCK) 
           on c.cost_num = pl.pl_record_key and 
              pl.pl_owner_code = 'C'                            
        left outer join dbo.allocation alloc 
           on alloc.alloc_num = c.cost_owner_key1 and 
              cost_owner_code in ('A', 'AA', 'AI')                
        left outer join dbo.account a1 WITH (NOLOCK) 
           on a1.acct_num = c.acct_num                            
        left outer join dbo.trade_item_curr tic 
           on tic.trade_num = pl.pl_secondary_owner_key1 and 
              tic.order_num = pl.pl_secondary_owner_key2 and 
              tic.item_num = pl.pl_secondary_owner_key3                        
where pl_type not in ('W', 'I')                        
GO
GRANT SELECT ON  [dbo].[v_POSGRID_pl_detail] TO [next_usr]
GO
