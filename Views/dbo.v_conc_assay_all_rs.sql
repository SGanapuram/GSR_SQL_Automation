SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_assay_all_rs]
(
    oid,
    conc_contract_oid,
    conc_prior_ver_oid,
    spec_code,
    spec_uom_code,
    per_spec_uom_code,
    spec_min_value,
    spec_min_value_text,
    spec_max_value,
    spec_max_value_text,
    spec_typical_value,
    spec_typical_value_text,
    spec_regulatory_limit,
    spec_regulatory_limit_text,
    primary_type,
    secondary_type,
    row_order_num,
    analysis_basis,
    umpire_rule,
    sl_applicable,
    splitting_limit,
	trans_id,
	resp_trans_id
)
as
select
    ct.oid,
    ct.conc_contract_oid,
    ct.conc_prior_ver_oid,
    ct.spec_code,
    ct.spec_uom_code,
    ct.per_spec_uom_code,
    ct.spec_min_value,
    ct.spec_min_value_text,
    ct.spec_max_value,
    ct.spec_max_value_text,
    ct.spec_typical_value,
    ct.spec_typical_value_text,
    ct.spec_regulatory_limit,
    ct.spec_regulatory_limit_text,
    ct.primary_type,
    ct.secondary_type,
    ct.row_order_num,
    ct.analysis_basis,
    ct.umpire_rule,
    ct.sl_applicable,
    ct.splitting_limit,
    ct.trans_id,
	null
from dbo.conc_assay ct
        left outer join dbo.icts_transaction it
           on ct.trans_id = it.trans_id
union
select
    ct.oid,
    ct.conc_contract_oid,
    ct.conc_prior_ver_oid,
    ct.spec_code,
    ct.spec_uom_code,
    ct.per_spec_uom_code,
    ct.spec_min_value,
    ct.spec_min_value_text,
    ct.spec_max_value,
    ct.spec_max_value_text,
    ct.spec_typical_value,
    ct.spec_typical_value_text,
    ct.spec_regulatory_limit,
    ct.spec_regulatory_limit_text,
    ct.primary_type,
    ct.secondary_type,
    ct.row_order_num,
    ct.analysis_basis,
    ct.umpire_rule,
    ct.sl_applicable,
    ct.splitting_limit,
	ct.trans_id,
	ct.resp_trans_id
from dbo.aud_conc_assay ct
        left outer join dbo.icts_transaction it
           on ct.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_assay_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_assay_all_rs] TO [next_usr]
GO
