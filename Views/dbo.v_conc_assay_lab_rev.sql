SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_assay_lab_rev]
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
as select
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	assay_lab_code,
	final_binding_ind,
	umpire_ind,
	trans_id,
	resp_trans_id
from dbo.aud_conc_assay_lab                                                                                                                                     
GO
GRANT SELECT ON  [dbo].[v_conc_assay_lab_rev] TO [next_usr]
GO
