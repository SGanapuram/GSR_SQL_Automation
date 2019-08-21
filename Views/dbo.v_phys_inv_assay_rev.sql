SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
create view [dbo].[v_phys_inv_assay_rev]                              
(                                                     
	exec_inv_num,
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
	owner_assay_oid,
	owner_assay,	
	trans_id,
	asof_trans_id,
	resp_trans_id
)                                                        
as                                                       
select                                                   
	exec_inv_num,
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
	owner_assay_oid,
	owner_assay,	
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_phys_inv_assay                                 
GO
GRANT SELECT ON  [dbo].[v_phys_inv_assay_rev] TO [next_usr]
GO
