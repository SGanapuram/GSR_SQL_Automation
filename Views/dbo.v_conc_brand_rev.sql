SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_brand_rev]
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
   oid,
   conc_contract_oid,
   version_num,
   conc_prior_ver_oid,
   brand_code,
   trans_id,
   resp_trans_id
from dbo.aud_conc_brand                                                                                                                                          
GO
GRANT SELECT ON  [dbo].[v_conc_brand_rev] TO [next_usr]
GO
