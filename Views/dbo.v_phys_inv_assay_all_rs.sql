SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_phys_inv_assay_all_rs]
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
	resp_trans_id,
	trans_type,
	trans_user_init,  
	tran_date,   
	app_name,   
	workstation_id,  
	sequence                                                     
)                                                                
as                                                               
select                                                           
	phy.exec_inv_num,
	phy.assay_group_num,
	phy.assay_date,
	phy.spec_code,
	phy.spec_actual_value,
	phy.spec_actual_value_text,
	phy.spec_opt_val,
	phy.spec_provisional_val,
	phy.spec_provisional_text,
	phy.spec_provisiional_opt_val,
	phy.use_in_formula_ind,
	phy.use_in_cost_ind,
	phy.use_in_pl_ind,
	phy.owner_assay_oid,
	phy.owner_assay,	
	phy.trans_id,
	null,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                 
from dbo.phys_inv_assay phy                              
    left outer join dbo.icts_transaction it                      
        on phy.trans_id = it.trans_id                    
union                                                            
select                                                           
	phy.exec_inv_num,
	phy.assay_group_num,
	phy.assay_date,
	phy.spec_code,
	phy.spec_actual_value,
	phy.spec_actual_value_text,
	phy.spec_opt_val,
	phy.spec_provisional_val,
	phy.spec_provisional_text,
	phy.spec_provisiional_opt_val,
	phy.use_in_formula_ind,
	phy.use_in_cost_ind,
	phy.use_in_pl_ind,
	phy.owner_assay_oid,
	phy.owner_assay,	
	phy.trans_id,
	phy.resp_trans_id,
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                               
from dbo.aud_phys_inv_assay phy                           
    left outer join dbo.icts_transaction it                      
        on phy.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_phys_inv_assay_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_phys_inv_assay_all_rs] TO [next_usr]
GO
