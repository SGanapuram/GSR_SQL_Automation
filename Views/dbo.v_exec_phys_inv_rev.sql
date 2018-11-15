SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
CREATE view [dbo].[v_exec_phys_inv_rev]                              
(                                                        
	exec_inv_num,
	trade_num,
	order_num,
	item_num,
	version_num,
	contract_execution_oid,
	conc_del_item_oid,
	cmdty_code,
	brand_id,
	del_term_code,
	del_loc_code,
	wsmd_loc_code,
	real_port_num,
	pos_num,
	inv_proj_qty,
	inv_actual_qty,
	inv_qty_uom_code,
	inv_sec_proj_qty,
	inv_sec_actual_qty,
	inv_adj_qty,
	inv_sec_adj_qty,
	inv_unit_price,
	inv_price_curr_code,
	inv_price_uom_code,
	inv_matched_qty,
	inv_matched_qty_uom_code,
	inv_sec_qty_uom_code,
	p_s_ind, 	
	trans_id,
	asof_trans_id,
	resp_trans_id	
)                                                        
as                                                       
select                                                   
	exec_inv_num,
	trade_num,
	order_num,
	item_num,
	version_num,
	contract_execution_oid,
	conc_del_item_oid,
	cmdty_code,
	brand_id,
	del_term_code,
	del_loc_code,
	wsmd_loc_code,
	real_port_num,
	pos_num,
	inv_proj_qty,
	inv_actual_qty,
	inv_qty_uom_code,
	inv_sec_proj_qty,
	inv_sec_actual_qty,
	inv_adj_qty,
	inv_sec_adj_qty,
	inv_unit_price,
	inv_price_curr_code,
	inv_price_uom_code,
	inv_matched_qty,
	inv_matched_qty_uom_code,
	inv_sec_qty_uom_code,
	p_s_ind,	
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_exec_phys_inv                                 
GO
GRANT SELECT ON  [dbo].[v_exec_phys_inv_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_exec_phys_inv_rev] TO [next_usr]
GO
