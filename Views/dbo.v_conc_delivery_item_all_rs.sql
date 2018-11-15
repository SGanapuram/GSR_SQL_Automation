SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_delivery_item_all_rs]
(
	oid,
	trade_num,
	order_num,
	item_num,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	del_date_from,
	del_date_to,
	min_qty,
	min_qty_uom_code,
	max_qty,
	max_qty_uom_code,
	del_status_ind,
	actual_qty,
	actual_qty_uom_code,
	contract_execution_oid,
	title_document_num,
	cmnt_num,
	total_exec_qty,
	total_exec_qty_uom_code,	
	del_qty,
	del_qty_uom_code,
	conc_delivery_schedule_oid,
	prorated_flat_amt,
	flat_amt_curr_code,
    custom_delivery_lot_id,	
	trans_id,
	resp_trans_id
)
as
select
    cd.oid,
	cd.trade_num,
	cd.order_num,
	cd.item_num,
	cd.conc_contract_oid,
	cd.version_num,
	cd.conc_prior_ver_oid,
	cd.del_date_from,
	cd.del_date_to,
	cd.min_qty,
	cd.min_qty_uom_code,
	cd.max_qty,
	cd.max_qty_uom_code,
	cd.del_status_ind,
	cd.actual_qty,
	cd.actual_qty_uom_code,
	cd.contract_execution_oid,
	cd.title_document_num,
	cd.cmnt_num,
	cd.total_exec_qty,
	cd.total_exec_qty_uom_code,
	cd.del_qty,
	cd.del_qty_uom_code,
    cd.conc_delivery_schedule_oid,
	cd.prorated_flat_amt,
	cd.flat_amt_curr_code,
    cd.custom_delivery_lot_id,    
	cd.trans_id,
	null
from dbo.conc_delivery_item cd
        left outer join dbo.icts_transaction it
           on cd.trans_id = it.trans_id
union
select
	cd.oid,
	cd.trade_num,
	cd.order_num,
	cd.item_num,
	cd.conc_contract_oid,
	cd.version_num,
	cd.conc_prior_ver_oid,
	cd.del_date_from,
	cd.del_date_to,
	cd.min_qty,
	cd.min_qty_uom_code,
	cd.max_qty,
	cd.max_qty_uom_code,
	cd.del_status_ind,
	cd.actual_qty,
	cd.actual_qty_uom_code,
	cd.contract_execution_oid,
	cd.title_document_num,
	cd.cmnt_num,
	cd.total_exec_qty,
	cd.total_exec_qty_uom_code,	
	cd.del_qty,
	cd.del_qty_uom_code,
    cd.conc_delivery_schedule_oid,
	cd.prorated_flat_amt,
	cd.flat_amt_curr_code,	
	cd.custom_delivery_lot_id,	
	cd.trans_id,
    cd.resp_trans_id
from dbo.aud_conc_delivery_item cd
        left outer join dbo.icts_transaction it
           on cd.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_delivery_item_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_delivery_item_all_rs] TO [next_usr]
GO
