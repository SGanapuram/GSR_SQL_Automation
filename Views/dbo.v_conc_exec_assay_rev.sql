SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_exec_assay_rev]
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
as select
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
from aud_conc_exec_assay
GO
GRANT SELECT ON  [dbo].[v_conc_exec_assay_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_exec_assay_rev] TO [next_usr]
GO
