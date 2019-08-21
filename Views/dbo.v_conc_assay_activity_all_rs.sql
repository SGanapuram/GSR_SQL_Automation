SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_assay_activity_all_rs]
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
as
select
   oid,
	ca.conc_contract_oid,
	ca.version_num,
	ca.conc_prior_ver_oid,
	ca.assay_activity_code,
	ca.target,
	ca.time,
	ca.activity_trigger,
	ca.trans_id,
	null
from dbo.conc_assay_activity ca
        left outer join dbo.icts_transaction it
           on ca.trans_id = it.trans_id
union
select
	ca.oid,
	ca.conc_contract_oid,
	ca.version_num,
	ca.conc_prior_ver_oid,
	ca.assay_activity_code,
	ca.target,
	ca.time,
	ca.activity_trigger,
	ca.trans_id,
    ca.resp_trans_id
from dbo.aud_conc_assay_activity ca
        left outer join dbo.icts_transaction it
           on ca.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_assay_activity_all_rs] TO [next_usr]
GO
