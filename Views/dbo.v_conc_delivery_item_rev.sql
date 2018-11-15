SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_delivery_item_rev]
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
from dbo.aud_conc_delivery_item
GO
GRANT SELECT ON  [dbo].[v_conc_delivery_item_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_delivery_item_rev] TO [next_usr]
GO
