SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_assay_rev]
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
as select
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
from dbo.aud_conc_assay
GO
GRANT SELECT ON  [dbo].[v_conc_assay_rev] TO [next_usr]
GO
