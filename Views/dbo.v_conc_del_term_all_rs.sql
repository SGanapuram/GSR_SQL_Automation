SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_del_term_all_rs]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	term_type,
	loc_type,
	loc_code,
	del_term_code,
	loc_country_code,
	trans_id,
	resp_trans_id
)
as
select
    cd.oid,
	cd.conc_contract_oid,
	cd.version_num,
	cd.conc_prior_ver_oid,
	cd.term_type,
	cd.loc_type,
	cd.loc_code,
	cd.del_term_code,
	cd.loc_country_code,
	cd.trans_id,
	null
from dbo.conc_del_term cd
        left outer join dbo.icts_transaction it
           on cd.trans_id = it.trans_id
union
select
	cd.oid,
	cd.conc_contract_oid,
	cd.version_num,
	cd.conc_prior_ver_oid,
	cd.term_type,
	cd.loc_type,
	cd.loc_code,
	cd.del_term_code,
	cd.loc_country_code,
	cd.trans_id,
    cd.resp_trans_id
from dbo.aud_conc_del_term cd
        left outer join dbo.icts_transaction it
           on cd.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_del_term_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_del_term_all_rs] TO [next_usr]
GO
