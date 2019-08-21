SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_brand_all_rs]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	brand_code,
	trans_id,
	resp_trans_id
)
as
select
    cb.oid,
	cb.conc_contract_oid,
	cb.version_num,
	cb.conc_prior_ver_oid,
	cb.brand_code,
	cb.trans_id,
	null
from dbo.conc_brand cb
        left outer join dbo.icts_transaction it
           on cb.trans_id = it.trans_id
union
select
	cb.oid,
	cb.conc_contract_oid,
	cb.version_num,
	cb.conc_prior_ver_oid,
	cb.brand_code,
	cb.trans_id,
    cb.resp_trans_id
from dbo.aud_conc_brand cb
        left outer join dbo.icts_transaction it
           on cb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_brand_all_rs] TO [next_usr]
GO
