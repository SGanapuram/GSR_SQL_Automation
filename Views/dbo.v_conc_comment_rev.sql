SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_comment_rev]
(
	oid,
	conc_contract_oid,
	version_num,
	conc_prior_ver_oid,
	cmnt_num,
	cmnt_creator_init,
	cmnt_mod_init,
	cmnt_creation_date,
	cmnt_last_mod_date,
	trans_id,
	resp_trans_id
)
as 
select
   oid,
   conc_contract_oid,
   version_num,
   conc_prior_ver_oid,
   cmnt_num,
   cmnt_creator_init,
   cmnt_mod_init,
   cmnt_creation_date,
   cmnt_last_mod_date,
   trans_id,
   resp_trans_id
from aud_conc_comment                                                                                                                                          
GO
GRANT SELECT ON  [dbo].[v_conc_comment_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_comment_rev] TO [next_usr]
GO
