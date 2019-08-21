SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_exec_logistics_details_all_rs]
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
	trans_id,
	resp_trans_id,
	contract_exec_oid
)
as
select
	eld.oid,
	eld.group_num,
	eld.line_num,
	eld.conc_exec_weight_oid,
	eld.conc_ref_result_type_oid,
	eld.from_date,
	eld.from_date_actual_ind,
	eld.to_date,
	eld.to_date_actual_ind,
	eld.mot_desc,
	eld.transporter_name,
	eld.title_passage_date,
	eld.title_date_actual_ind,
	eld.trans_id,
	null,
	eld.contract_exec_oid	
from dbo.exec_logistics_details eld
    left outer join dbo.icts_transaction it
        on eld.trans_id = it.trans_id
union
select
	eld.oid,
	eld.group_num,
	eld.line_num,
	eld.conc_exec_weight_oid,
	eld.conc_ref_result_type_oid,
	eld.from_date,
	eld.from_date_actual_ind,
	eld.to_date,
	eld.to_date_actual_ind,
	eld.mot_desc,
	eld.transporter_name,
	eld.title_passage_date,
	eld.title_date_actual_ind,
	eld.trans_id,
	eld.resp_trans_id,
	eld.contract_exec_oid
from dbo.aud_exec_logistics_details eld
    left outer join dbo.icts_transaction it
        on eld.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_exec_logistics_details_all_rs] TO [next_usr]
GO
