SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_comment_all_rs]
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
	cc.oid,
	cc.conc_contract_oid,
	cc.version_num,
	cc.conc_prior_ver_oid,
	cc.cmnt_num,
	cc.cmnt_creator_init,
	cc.cmnt_mod_init,
	cc.cmnt_creation_date,
	cc.cmnt_last_mod_date,
	cc.trans_id,
	null
from dbo.conc_comment cc
        left outer join dbo.icts_transaction it
           on cc.trans_id = it.trans_id
union
select
	cc.oid,
	cc.conc_contract_oid,
	cc.version_num,
	cc.conc_prior_ver_oid,
	cc.cmnt_num,
	cc.cmnt_creator_init,
	cc.cmnt_mod_init,
	cc.cmnt_creation_date,
	cc.cmnt_last_mod_date,
	cc.trans_id,
    cc.resp_trans_id
from dbo.aud_conc_comment cc
        left outer join dbo.icts_transaction it
           on cc.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_comment_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_comment_all_rs] TO [next_usr]
GO
