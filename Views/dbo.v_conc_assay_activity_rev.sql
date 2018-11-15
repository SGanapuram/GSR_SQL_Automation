SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_assay_activity_rev]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	assay_activity_code,
	target,
	time,
	activity_trigger,
	trans_id,
	resp_trans_id
)
as select
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	assay_activity_code,
	target,
	time,
	activity_trigger,
	trans_id,
	resp_trans_id
from aud_conc_assay_activity                                                                                                                                            
GO
GRANT SELECT ON  [dbo].[v_conc_assay_activity_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_assay_activity_rev] TO [next_usr]
GO
