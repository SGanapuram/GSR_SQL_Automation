SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_exec_weight_rev]
(
oid,
	contract_execution_oid,
	measure_date,
	loc_code,
	prim_qty,
	prim_qty_uom_code,
	sec_qty,
	sec_qty_uom_code,
	short_comment,
	use_in_pl_ind,
	weight_type,
	weight_detail_num,	
	group_num,
	line_num,
	conc_ref_result_type_oid,
	result_date,
	conc_ref_document_oid,
	title_ind,
	moisture_percent,
	franchise_percent,
	insp_acct_num,
	cargo_condition_code,
	final_ind,
	loc_type_code,
	loc_country_code,
	trans_id,
	resp_trans_id
)
as select
oid,
	contract_execution_oid,
	measure_date,
	loc_code,
	prim_qty,
	prim_qty_uom_code,
	sec_qty,
	sec_qty_uom_code,
	short_comment,
	use_in_pl_ind,
	weight_type,
	weight_detail_num,
	group_num,
	line_num,
	conc_ref_result_type_oid,
	result_date,
	conc_ref_document_oid,
	title_ind,
	moisture_percent,
	franchise_percent,
	insp_acct_num,
	cargo_condition_code,
	final_ind,
	loc_type_code,
	loc_country_code,	
	trans_id,
	resp_trans_id
from aud_conc_exec_weight
GO
GRANT SELECT ON  [dbo].[v_conc_exec_weight_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_exec_weight_rev] TO [next_usr]
GO
