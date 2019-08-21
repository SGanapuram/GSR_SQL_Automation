SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_CHGHISTORY_uic_updates]
(
   change_id,
   dataset_name,
   trade_num,
   order_num, 
   item_num,
   cost_num, 
   alloc_num, 
   alloc_item_num,
   data_element,
   old_value,
   new_value,
   who_did,
   mod_date
)
as
select urm.oid,
       'TRADE',
       urm.key1,
       urm.key2,
       urm.key3,
       null,
       null,
       null,
       urvc.description,
       urh.old_value,
       urh.new_value,
       iu.user_first_name + ' ' + iu.user_last_name,      
       tran_date       
from dbo.uic_report_modification urm
        join dbo.uic_reporting_history urh 
           on urm.oid = urh.report_mod_id
        join dbo.uic_rpt_values_config urvc 
           on urvc.oid = urh.values_config_id
        join dbo.icts_entity_name ien with (nolock)
           on urvc.entity_id = ien.oid and
              ien.entity_name = 'TradeItem'
	      join dbo.icts_user iu with (nolock)
	         on iu.user_init = urm.user_init
where urm.operation_type = 'U'
union all
select urm.oid,
       'COST',
       null,
       null,
       null,
       urm.key1,
       null,
       null,
       urvc.description,
       urh.old_value,
       urh.new_value,
       iu.user_first_name + ' ' + iu.user_last_name,      
       tran_date       
from dbo.uic_report_modification urm
        join dbo.uic_reporting_history urh 
           on urm.oid = urh.report_mod_id
        join dbo.uic_rpt_values_config urvc 
           on urvc.oid = urh.values_config_id
        join dbo.icts_entity_name ien with (nolock) 
           on urvc.entity_id = ien.oid and
              ien.entity_name = 'Cost'
	      join dbo.icts_user iu with (nolock)
	         on iu.user_init = urm.user_init
where urm.operation_type = 'U'
union all
select urm.oid,
       'ALLOCATION',
       null,
       null,
       null,
       null,
       urm.key1,
       urm.key2,
       urvc.description,
       urh.old_value,
       urh.new_value,
       iu.user_first_name + ' ' + iu.user_last_name,      
       tran_date       
from dbo.uic_report_modification urm
        join dbo.uic_reporting_history urh 
           on urm.oid = urh.report_mod_id
        join dbo.uic_rpt_values_config urvc 
           on urvc.oid = urh.values_config_id
        join dbo.icts_entity_name ien with (nolock) 
           on urvc.entity_id = ien.oid and
              ien.entity_name = 'AllocationItem'
	      join dbo.icts_user iu with (nolock)
	         on iu.user_init = urm.user_init
where urm.operation_type = 'U'
GO
GRANT SELECT ON  [dbo].[v_CHGHISTORY_uic_updates] TO [next_usr]
GO
