SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_conc_contract_prior_version_all_rs]
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
as
select
    ct.oid,
	ct.conc_contract_oid,
	ct.custom_contract_num,
	ct.version_num,
	ct.custom_contract_id,
	ct.external_reference,
	ct.p_s_ind,
	ct.contractual_type,
	ct.contract_year,
	ct.book_comp_num,
	ct.acct_num,
	ct.cmdty_code,
	ct.conc_brand_id,
	ct.workflow_status_code,
	ct.contract_status_code,
	ct.trader_init,
	ct.traffic_operator,
	ct.cargo_conditioning,
	ct.weighing_method_code,
	ct.orig_contr_qty,
	ct.total_contr_qty,
	ct.total_execution_qty,
	ct.totoal_open_contr_qty,
	ct.total_contr_min,
	ct.total_contr_max,
	ct.real_port_num,
	ct.formula_num,
	ct.trans_id,
	null
from dbo.conc_contract_prior_version ct
        left outer join dbo.icts_transaction it
           on ct.trans_id = it.trans_id
union
select
	ct.oid,
	ct.conc_contract_oid,
	ct.custom_contract_num,
	ct.version_num,
	ct.custom_contract_id,
	ct.external_reference,
	ct.p_s_ind,
	ct.contractual_type,
	ct.contract_year,
	ct.book_comp_num,
	ct.acct_num,
	ct.cmdty_code,
	ct.conc_brand_id,
	ct.workflow_status_code,
	ct.contract_status_code,
	ct.trader_init,
	ct.traffic_operator,
	ct.cargo_conditioning,
	ct.weighing_method_code,
	ct.orig_contr_qty,
	ct.total_contr_qty,
	ct.total_execution_qty,
	ct.totoal_open_contr_qty,
	ct.total_contr_min,
	ct.total_contr_max,
	ct.real_port_num,
	ct.formula_num,
	ct.trans_id,
    ct.resp_trans_id
from dbo.aud_conc_contract_prior_version ct
        left outer join dbo.icts_transaction it
           on ct.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_conc_contract_prior_version_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_conc_contract_prior_version_all_rs] TO [next_usr]
GO
