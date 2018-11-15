SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_assay_lab_all_rs]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	assay_lab_code,
	final_binding_ind,
	umpire_ind,
	trans_id,
	resp_trans_id
)
as
select
    ca.oid,
	ca.conc_contract_oid,
	ca.version_num,
	ca.conc_prior_ver_oid,
	ca.assay_lab_code,
	ca.final_binding_ind,
	ca.umpire_ind,
	ca.trans_id,
	null
from dbo.conc_assay_lab ca
        left outer join dbo.icts_transaction it
           on ca.trans_id = it.trans_id
union
select
	ca.oid,
	ca.conc_contract_oid,
	ca.version_num,
	ca.conc_prior_ver_oid,
	ca.assay_lab_code,
	ca.final_binding_ind,
	ca.umpire_ind,
	ca.trans_id,
    ca.resp_trans_id
from dbo.aud_conc_assay_lab ca
        left outer join dbo.icts_transaction it
           on ca.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_assay_lab_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_assay_lab_all_rs] TO [next_usr]
GO
