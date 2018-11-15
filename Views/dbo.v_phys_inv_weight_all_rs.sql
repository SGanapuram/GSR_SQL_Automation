SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_phys_inv_weight_all_rs]
(
	exec_inv_num,
	measure_date,
	loc_code,
	prim_qty,
	prim_qty_uom_code,
	sec_qty,
	sec_qty_uom_code,
	short_comment,
    trans_id,
	resp_trans_id,
    use_in_pl_ind,
    weight_type,
	weight_detail_num,	
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
	phy.measure_date,
	phy.loc_code,
	phy.prim_qty,
	phy.prim_qty_uom_code,
	phy.sec_qty,
	phy.sec_qty_uom_code,
	phy.short_comment,
	phy.trans_id,
	null,
	phy.use_in_pl_ind,
	phy.weight_type,
	phy.weight_detail_num,	
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                 
from dbo.phys_inv_weight phy                              
        left outer join dbo.icts_transaction it                      
           on phy.trans_id = it.trans_id                    
union                                                            
select                                                           
	phy.exec_inv_num,
	phy.measure_date,
	phy.loc_code,
	phy.prim_qty,
	phy.prim_qty_uom_code,
	phy.sec_qty,
	phy.sec_qty_uom_code,
	phy.short_comment,
	phy.trans_id,	
	phy.resp_trans_id,
	phy.use_in_pl_ind,
	phy.weight_type,
	phy.weight_detail_num,	
	it.type, 
	it.user_init, 
	it.tran_date,   
	it.app_name,  
	it.workstation_id,  
	it.sequence                                                 
from dbo.aud_phys_inv_weight phy                           
        left outer join dbo.icts_transaction it                      
           on phy.trans_id = it.trans_id                    
GO
GRANT SELECT ON  [dbo].[v_phys_inv_weight_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_phys_inv_weight_all_rs] TO [next_usr]
GO
