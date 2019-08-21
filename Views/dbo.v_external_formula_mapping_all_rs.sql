SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_external_formula_mapping_all_rs] 
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
	spec_code,
	spec_uom_code,
	per_spec_uom_code,
	trans_id,
	resp_trans_id, 
	trans_type, 
	trans_user_init, 
	tran_date, 
	app_name, 
	workstation_id, 
	sequence 
) 
as 
select 
	pr.oid,
	pr.quote_string,
	pr.price_source,
	pr.commkt_key,
	pr.price_point,
	pr.ui_index,
	pr.ui_source,
	pr.ui_point,
	pr.ui_formula_str,
	pr.spec_code,
	pr.spec_uom_code,
	pr.per_spec_uom_code,
	pr.trans_id,
	null, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.external_formula_mapping pr 
        left outer join dbo.icts_transaction it 
           on pr.trans_id = it.trans_id 
union 
select 
	pr.oid,
	pr.quote_string,
	pr.price_source,
	pr.commkt_key,
	pr.price_point,
	pr.ui_index,
	pr.ui_source,
	pr.ui_point,
	pr.ui_formula_str,
	pr.spec_code,
	pr.spec_uom_code,
	pr.per_spec_uom_code,	
	pr.trans_id,
	pr.resp_trans_id, 
	it.type, 
	it.user_init, 
	it.tran_date, 
	it.app_name, 
	it.workstation_id, 
	it.sequence 
from dbo.aud_external_formula_mapping pr 
        left outer join dbo.icts_transaction it 
           on pr.trans_id = it.trans_id 
GO
GRANT SELECT ON  [dbo].[v_external_formula_mapping_all_rs] TO [next_usr]
GO
