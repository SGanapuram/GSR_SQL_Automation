SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_exec_weight_all_rs]
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
as
select
	cew.oid,
	cew.contract_execution_oid,
	cew.measure_date,
	cew.loc_code,
	cew.prim_qty,
	cew.prim_qty_uom_code,
	cew.sec_qty,
	cew.sec_qty_uom_code,
	cew.short_comment,
	cew.use_in_pl_ind,
	cew.weight_type,	
	cew.weight_detail_num,
	cew.group_num,
	cew.line_num,
	cew.conc_ref_result_type_oid,
	cew.result_date,
	cew.conc_ref_document_oid,
	cew.title_ind,
	cew.moisture_percent,
	cew.franchise_percent,
	cew.insp_acct_num,
	cew.cargo_condition_code,
	cew.final_ind,
	cew.loc_type_code,
	cew.loc_country_code,	
	cew.trans_id,	
	null
from dbo.aud_conc_exec_weight cew
    left outer join dbo.icts_transaction it
        on cew.trans_id = it.trans_id
union
select
	cew.oid,
	cew.contract_execution_oid,
	cew.measure_date,
	cew.loc_code,
	cew.prim_qty,
	cew.prim_qty_uom_code,
	cew.sec_qty,
	cew.sec_qty_uom_code,
	cew.short_comment,
	cew.use_in_pl_ind,
	cew.weight_type,
	cew.weight_detail_num,
	cew.group_num,
	cew.line_num,
	cew.conc_ref_result_type_oid,
	cew.result_date,
	cew.conc_ref_document_oid,
	cew.title_ind,
	cew.moisture_percent,
	cew.franchise_percent,
	cew.insp_acct_num,
	cew.cargo_condition_code,
	cew.final_ind,
	cew.loc_type_code,
	cew.loc_country_code,	
	cew.trans_id,
    cew.resp_trans_id
from dbo.aud_conc_exec_weight cew
    left outer join dbo.icts_transaction it
        on cew.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_exec_weight_all_rs] TO [next_usr]
GO
