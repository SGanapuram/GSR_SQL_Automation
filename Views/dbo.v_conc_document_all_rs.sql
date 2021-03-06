SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_document_all_rs]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	doc_name,
	doc_description,
	doc_creator_init,
	doc_mod_init,
	doc_creation_date,
	doc_last_mod_date,
	doc_url,
	trans_id,
	resp_trans_id
)
as
select
    cd.oid,
	cd.conc_contract_oid,
	cd.version_num,
	cd.conc_prior_ver_oid,
	cd.doc_name,
	cd.doc_description,
	cd.doc_creator_init,
	cd.doc_mod_init,
	cd.doc_creation_date,
	cd.doc_last_mod_date,
	cd.doc_url,
	cd.trans_id,
	null
from dbo.conc_document cd
        left outer join dbo.icts_transaction it
           on cd.trans_id = it.trans_id
union
select
	cd.oid,
	cd.conc_contract_oid,
	cd.version_num,
	cd.conc_prior_ver_oid,
	cd.doc_name,
	cd.doc_description,
	cd.doc_creator_init,
	cd.doc_mod_init,
	cd.doc_creation_date,
	cd.doc_last_mod_date,
	cd.doc_url,
	cd.trans_id,
    cd.resp_trans_id
from dbo.aud_conc_document cd
        left outer join dbo.icts_transaction it
           on cd.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_document_all_rs] TO [next_usr]
GO
