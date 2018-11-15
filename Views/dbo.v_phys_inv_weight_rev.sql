SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                      
CREATE view [dbo].[v_phys_inv_weight_rev]                              
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
	asof_trans_id,
	resp_trans_id,
    use_in_pl_ind,
    weight_type,
	weight_detail_num
)                                                        
as                                                       
select                                                   
	exec_inv_num,
	measure_date,
	loc_code,
	prim_qty,
	prim_qty_uom_code,
	sec_qty,
	sec_qty_uom_code,
	short_comment,
	trans_id,
	trans_id,
	resp_trans_id,
    use_in_pl_ind,
    weight_type,
	weight_detail_num
from dbo.aud_phys_inv_weight                                 
GO
GRANT SELECT ON  [dbo].[v_phys_inv_weight_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_phys_inv_weight_rev] TO [next_usr]
GO
