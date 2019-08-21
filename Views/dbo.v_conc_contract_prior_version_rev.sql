SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_conc_contract_prior_version_rev]
(
	oid,
	conc_contract_oid,
	custom_contract_num,
	version_num,
	custom_contract_id,
	external_reference,
	p_s_ind,
	contractual_type,
	contract_year,
	book_comp_num,
	acct_num,
	cmdty_code,
	conc_brand_id,
	workflow_status_code,
	contract_status_code,
	trader_init,
	traffic_operator,
	cargo_conditioning,
	weighing_method_code,
	orig_contr_qty,
	total_contr_qty,
	total_execution_qty,
	totoal_open_contr_qty,
	total_contr_min,
	total_contr_max,
	real_port_num,
	formula_num,
	trans_id,
	resp_trans_id
)
as select
  	oid,
	conc_contract_oid,
	custom_contract_num,
	version_num,
	custom_contract_id,
	external_reference,
	p_s_ind,
	contractual_type,
	contract_year,
	book_comp_num,
	acct_num,
	cmdty_code,
	conc_brand_id,
	workflow_status_code,
	contract_status_code,
	trader_init,
	traffic_operator,
	cargo_conditioning,
	weighing_method_code,
	orig_contr_qty,
	total_contr_qty,
	total_execution_qty,
	totoal_open_contr_qty,
	total_contr_min,
	total_contr_max,
	real_port_num,
    formula_num,
	trans_id,
	resp_trans_id
from dbo.aud_conc_contract_prior_version
GO
GRANT SELECT ON  [dbo].[v_conc_contract_prior_version_rev] TO [next_usr]
GO
