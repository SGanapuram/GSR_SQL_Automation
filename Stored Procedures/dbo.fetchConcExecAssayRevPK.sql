SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fetchConcExecAssayRevPK]
   @asof_trans_id   bigint,
   @oid       		int
as
declare @trans_id   bigint

   select @trans_id = trans_id
   from dbo.conc_exec_assay
   where oid = @oid

if @trans_id <= @asof_trans_id
begin
   select
	asof_trans_id = @asof_trans_id,
	assay_date,
	assay_group_num,
	assay_lab_code,
	conc_exec_weight_oid,	
	conc_ref_result_type_oid,
	contract_execution_oid,
	line_num,
	oid,	
	resp_trans_id = NULL,
	result_date,
	spec_actual_value,
	spec_actual_value_text,
	spec_code,
	spec_opt_val,
	spec_provisiional_opt_val,
	spec_provisional_text,
	spec_provisional_val,
	trans_id,
	use_in_cost_ind,
	use_in_formula_ind,
	use_in_pl_ind
	from dbo.conc_exec_assay
	where oid = @oid
end
else
begin
   set rowcount 1
   select 
	asof_trans_id = @asof_trans_id,
	assay_date,
	assay_group_num,
	assay_lab_code,
	conc_exec_weight_oid,
	conc_ref_result_type_oid,	
	contract_execution_oid,
	line_num,
	oid,
	resp_trans_id,
	result_date,
	spec_actual_value,
	spec_actual_value_text,
	spec_code,
	spec_opt_val,
	spec_provisiional_opt_val,
	spec_provisional_text,
	spec_provisional_val,
	trans_id,
	use_in_cost_ind,
	use_in_formula_ind,
	use_in_pl_ind
	from dbo.aud_conc_exec_assay
   where oid = @oid and
         trans_id <= @asof_trans_id and
	       resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchConcExecAssayRevPK] TO [next_usr]
GO
