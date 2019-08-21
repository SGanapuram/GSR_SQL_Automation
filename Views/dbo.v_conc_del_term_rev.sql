SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_del_term_rev]
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
from aud_conc_del_term
GO
GRANT SELECT ON  [dbo].[v_conc_del_term_rev] TO [next_usr]
GO
