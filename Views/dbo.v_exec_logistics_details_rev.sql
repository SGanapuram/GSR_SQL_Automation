SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_exec_logistics_details_rev]
(  
	 oid,  
	 group_num,  
	 line_num,  
	 conc_exec_weight_oid,  
	 conc_ref_result_type_oid,  
	 from_date,  
	 from_date_actual_ind,  
	 to_date,  
	 to_date_actual_ind,  
	 mot_desc,  
	 transporter_name,  
	 title_passage_date,  
	 title_date_actual_ind,  
	 contract_exec_oid,  
	 trans_id, 
	 asof_trans_id,  
	 resp_trans_id 
)  
as 
select  
	 oid,  
	 group_num,  
	 line_num,  
	 conc_exec_weight_oid,  
	 conc_ref_result_type_oid,  
	 from_date,  
	 from_date_actual_ind,  
	 to_date,  
	 to_date_actual_ind,  
	 mot_desc,  
	 transporter_name,  
	 title_passage_date,  
	 title_date_actual_ind, 
	 contract_exec_oid,  
	 trans_id,  
	 trans_id,  
	 resp_trans_id 
from aud_exec_logistics_details  
GO
GRANT SELECT ON  [dbo].[v_exec_logistics_details_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_exec_logistics_details_rev] TO [next_usr]
GO
