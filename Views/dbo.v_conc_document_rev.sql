SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_document_rev]
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
from dbo.aud_conc_document
GO
GRANT SELECT ON  [dbo].[v_conc_document_rev] TO [next_usr]
GO
