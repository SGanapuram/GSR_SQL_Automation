SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_uic_report]            
(            
   tran_date,             
   entity_name,            
   oid,            
   profit_center,            
   real_port_num,            
   port_short_name,            
   icts_user_name,             
   acct_full_name,                
   key1,             
   key2,             
   key3,            
   other_data1,            
   other_data2,            
   operation,            
   dataelement,             
   old_value,             
   new_value,            
   entity_value_selector,      
   values_config_oid,      
   resp_trans_id          
)            
AS                   
select             
   convert(datetime, convert(char, tran_date, 101)) 'ModDate',             
   entity_name 'TransactionType',            
   oid 'ChangeID',            
   pt.tag_value 'ProfitCenter',            
   p.port_num 'PortfolioNum',            
   p.port_short_name 'PortfolioName',            
   iu.user_first_name + ' ' + iu.user_last_name 'User',             
   te.acct_full_name 'TradingEntity',                
   key1,             
   key2,             
   key3,            
   other_data1 'OtherData1',            
   other_data2 'OtherData2',            
   operation 'Operation',            
   dataelement 'DataElement',             
   old_value 'OldValue',             
   new_value 'NewValue',        
   entity_value_selector,      
   values_config_oid,          
   resp_trans_id            
from (select             
         tran_date,             
         urm.resp_trans_id,            
         entity_name,            
         urm.oid,            
         key1,             
         key2,             
         key3,            
         null 'other_data1',            
         null 'other_data2',            
         case when operation_type = 'I' then 'NEW'   
        when operation_type = 'U' then 'Modified'   
     when operation_type = 'D' then 'Delete'   
   end operation,            
         description 'dataelement',             
         old_value 'old_value',             
         new_value 'new_value',            
         ti.real_port_num 'port_num',            
         urm.user_init 'user_init',      
         urvc.entity_value_selector,      
         urvc.oid values_config_oid      
      from dbo.uic_report_modification urm            
             join dbo.uic_reporting_history urh   
       on urm.oid = urh.report_mod_id            
             join dbo.uic_rpt_values_config urvc   
       on urvc.oid = urh.values_config_id            
             join dbo.icts_entity_name ien   
       on urvc.entity_id = ien.oid            
             join dbo.allocation_item ai   
       on key1 = ai.alloc_num and   
       key2 = ai.alloc_item_num            
             left outer join dbo.trade_item ti   
       on ti.trade_num = ai.trade_num and   
       ti.order_num = ai.order_num and   
       ti.item_num = ai.item_num            
             left outer join dbo.trade t   
       on t.trade_num = ti.trade_num            
      where operation_type in ('U', 'D')   
      and entity_name in('AllocationItem', 'AllocationItemTransport')            
      --and tran_date>='01/02/2013'            
      union  
  --Allocation    
            select distinct            
      tran_date ,             
      urm.resp_trans_id,            
      entity_name ,            
      urm.oid ,            
      ai.alloc_num as key1,             
      ai.alloc_item_num as key2,             
      key3,            
      null 'other_data1',            
      null   'other_data2',            
      case when operation_type = 'I' then 'NEW' when operation_type = 'U' then 'Modified' when operation_type = 'D' then 'Delete' end operation,            
      description 'dataelement',             
      old_value 'old_value',             
      new_value 'new_value',            
      ti.real_port_num 'port_num',            
      urm.user_init 'user_init'     ,      
      urvc.entity_value_selector,      
      urvc.oid values_config_oid      
      from uic_report_modification urm            
      join uic_reporting_history urh on urm.oid=urh.report_mod_id            
      join uic_rpt_values_config urvc on urvc.oid=urh.values_config_id            
      join icts_entity_name ien on urvc.entity_id=ien.oid
      join allocation a on  key1=a.alloc_num
      join allocation_item ai on  a.alloc_num=ai.alloc_num            
      left outer join trade_item ti on ti.trade_num = ai.trade_num and ti.order_num = ai.order_num and ti.item_num = ai.item_num            
      left outer join trade t on t.trade_num = ti.trade_num            
      where operation_type in ('U','D')            
      and entity_name in('Allocation')                        
      union               
      -- Cost            
     select             
        tran_date 'ModDate',            
        urm.resp_trans_id,            
        entity_name 'TransactionType',            
        urm.oid 'ChangeID',            
        key1,             
        key2,             
        key3,                  
        c.cost_code 'OtherData1',            
        null 'OtherData2',            
        case when operation_type = 'I' then 'NEW'   
       when operation_type = 'U' then 'Modified'   
    when operation_type = 'D' then 'Delete'   
  end 'Operation',            
        description 'DataElement',            
        old_value 'OldValue',            
        new_value 'NewValue',            
        c.port_num 'port_num',            
        urm.user_init 'user_init' ,      
        urvc.entity_value_selector,      
        urvc.oid values_config_oid                 
    from dbo.uic_report_modification urm            
            join dbo.uic_reporting_history urh   
      on urm.oid = urh.report_mod_id            
            join dbo.uic_rpt_values_config urvc   
      on urvc.oid = urh.values_config_id            
            join dbo.icts_entity_name ien   
      on urvc.entity_id = ien.oid            
            join dbo.cost c   
      on key1 = c.cost_num            
            join dbo.account a   
      on a.acct_num = c.acct_num            
    where entity_name = 'Cost' and   
       description = 'Cost Amount'            
    union               
    -- Trade Item           
    select            
       tran_date 'ModDate',         
       urm.resp_trans_id,            
       entity_name 'TransactionType',            
       urm.oid 'ChangeID',            
       key1,             
       key2,             
       key3,             
       tro.order_type_code 'OtherData1',         
       t.creation_date 'OtherData2',            
       case when operation_type = 'I' then 'NEW'   
         when operation_type = 'U' then 'Modified'   
   when operation_type = 'D' then 'Delete'   
    end 'Operation',            
       description 'DataElement',            
       old_value 'OldValue',            
       new_value 'NewValue',            
       ti.real_port_num 'port_num',            
       urm.user_init 'user_init'  ,      
       urvc.entity_value_selector,      
       urvc.oid values_config_oid                
    from dbo.uic_report_modification urm            
            join dbo.uic_reporting_history urh   
      on urm.oid = urh.report_mod_id            
            join dbo.uic_rpt_values_config urvc   
      on urvc.oid = urh.values_config_id            
            join dbo.icts_entity_name ien   
      on urvc.entity_id = ien.oid            
            join dbo.trade_item ti   
      on key1 = ti.trade_num and   
         key2 = ti.order_num and   
      key3 = ti.item_num            
            join dbo.trade t   
      on t.trade_num = ti.trade_num            
            join dbo.trade_order tro   
      on tro.trade_num = ti.trade_num and   
         tro.order_num = ti.order_num            
    where entity_name in ('TradeItem',  
                       'TradeItemBunker',  
                          'TradeItemCashPhy',  
                          'TradeItemExchOpt',  
                          'TradeItemFut',  
                          'TradeItemOtcOpt',  
                          'TradeItemStorage',  
                          'TradeItemTransport',  
                          'TradeItemWetPhy',  
                          'TradeItemDryPhy') and   
          operation_type in ('U', 'D') and   
          description not in ('EstimateInd',  
                              'Includes Excise Tax',  
                              'Includes Fuel Tax',  
                              'Relative Declare Date Ind',  
                              'Relative Declare Date Type')              
 union    
    select            
       tran_date 'ModDate',         
       urm.resp_trans_id,            
       entity_name 'TransactionType',            
       urm.oid 'ChangeID',            
       ti.trade_num,           
       ti.order_num,           
       ti.item_num,             
       tro.order_type_code 'OtherData1',         
       t.creation_date 'OtherData2',            
       case when operation_type = 'I' then 'NEW'   
         when operation_type = 'U' then 'Modified'   
   when operation_type = 'D' then 'Delete'   
       end 'Operation',            
       description 'DataElement',            
       old_value 'OldValue',            
       new_value 'NewValue',            
       ti.real_port_num 'port_num',            
       urm.user_init 'user_init'  ,      
       urvc.entity_value_selector,      
       urvc.oid values_config_oid                
    from dbo.uic_report_modification urm            
           join dbo.uic_reporting_history urh   
        on urm.oid = urh.report_mod_id            
           join dbo.uic_rpt_values_config urvc   
        on urvc.oid = urh.values_config_id            
           join dbo.icts_entity_name ien   
        on urvc.entity_id = ien.oid            
           join dbo.trade t   
        on key1 = t.trade_num      
           join dbo.trade_order tro   
        on t.trade_num = tro.trade_num  
           join dbo.trade_item ti   
        on ti.trade_num = tro.trade_num and   
        ti.order_num = tro.order_num       
    where entity_name in ('Trade') and   
       operation_type in ('U', 'D') and   
    description not in ('EstimateInd',  
                        'Includes Excise Tax',  
         'Includes Fuel Tax',  
         'Relative Declare Date Ind',  
         'Relative Declare Date Type') ) uc            
   left outer join dbo.portfolio_tag pt   
      on pt.port_num = uc.port_num and   
      pt.tag_name = 'PRFTCNTR'            
   left outer join dbo.portfolio p   
      on p.port_num = uc.port_num            
   left outer join dbo.account te   
      on te.acct_num = p.trading_entity_num             
   left outer join dbo.icts_user iu   
      on iu.user_init = uc.user_init            
WHERE 1=1                  
GO
GRANT SELECT ON  [dbo].[v_uic_report] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_uic_report', NULL, NULL
GO
