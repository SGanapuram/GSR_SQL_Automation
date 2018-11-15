SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_exec_assay_all_rs]
(
	oid,
	contract_execution_oid,
	assay_group_num,
	assay_date,
	spec_code,
	spec_actual_value,
	spec_actual_value_text,
	spec_opt_val,
	spec_provisional_val,
	spec_provisional_text,
	spec_provisiional_opt_val,
	use_in_formula_ind,
	use_in_cost_ind,
	use_in_pl_ind,
	line_num,
	conc_ref_result_type_oid,
	result_date,
	assay_lab_code,
	conc_exec_weight_oid,
	use_in_hedge_ind,
	trans_id,
	resp_trans_id
)
as
select
   	cea.oid,
	cea.contract_execution_oid,
	cea.assay_group_num,
	cea.assay_date,
	cea.spec_code,
	cea.spec_actual_value,
	cea.spec_actual_value_text,
	cea.spec_opt_val,
	cea.spec_provisional_val,
	cea.spec_provisional_text,
	cea.spec_provisiional_opt_val,
	cea.use_in_formula_ind,
	cea.use_in_cost_ind,
	cea.use_in_pl_ind,
	cea.line_num,
	cea.conc_ref_result_type_oid,
	cea.result_date,
	cea.assay_lab_code,
	cea.conc_exec_weight_oid,
	cea.use_in_hedge_ind,	
	cea.trans_id,
	null
from dbo.aud_conc_exec_assay cea
    left outer join dbo.icts_transaction it
        on cea.trans_id = it.trans_id
union
select
   	cea.oid,
	cea.contract_execution_oid,
	cea.assay_group_num,
	cea.assay_date,
	cea.spec_code,
	cea.spec_actual_value,
	cea.spec_actual_value_text,
	cea.spec_opt_val,
	cea.spec_provisional_val,
	cea.spec_provisional_text,
	cea.spec_provisiional_opt_val,
	cea.use_in_formula_ind,
	cea.use_in_cost_ind,
	cea.use_in_pl_ind,
	cea.line_num,
	cea.conc_ref_result_type_oid,
	cea.result_date,
	cea.assay_lab_code,
	cea.conc_exec_weight_oid,
	cea.use_in_hedge_ind,	
	cea.trans_id,
    cea.resp_trans_id
from dbo.aud_conc_exec_assay cea 
    left outer join dbo.icts_transaction it
        on cea.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_exec_assay_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_exec_assay_all_rs] TO [next_usr]
GO
