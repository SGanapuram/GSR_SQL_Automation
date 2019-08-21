SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_external_formula_mapping_rev]
(
	oid,
	quote_string,
	price_source,
	commkt_key,
	price_point,
	ui_index,
	ui_source,
	ui_point,
	ui_formula_str,
	element_code,
	element_uom_code,
	spec_code,
	spec_uom_code,
	per_spec_uom_code,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select 
	oid,
	quote_string,
	price_source,
	commkt_key,
	price_point,
	ui_index,
	ui_source,
	ui_point,
	ui_formula_str,
	element_code,
	element_uom_code,
	spec_code,
	spec_uom_code,
	per_spec_uom_code,	
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_external_formula_mapping 
GO
GRANT SELECT ON  [dbo].[v_external_formula_mapping_rev] TO [next_usr]
GO
