SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fb_modular_info_rev]
(
	formula_num,
	formula_body_num,
	basis_cmdty_code,
	risk_mkt_code,
	risk_trading_prd,
	pay_deduct_ind,
	cross_ref_ind,
	ref_cmdty_code,
	price_pcnt_string,
	price_pcnt_value,
	price_quote_string,
	price_rule_oid,
	last_computed_value,
	last_computed_asof_date,
	line_item_contr_desc,
	line_item_invoice_desc,
	trans_id,
	asof_trans_id,   
	resp_trans_id ,
	qp_start_date,
	qp_end_date,
	qp_election_date,
	qp_desc,
	qp_election_opt,
	qp_elected,
	qp_type,
	qp_start_date_addl_days,
	qp_end_date_addl_days,
	lib_formula_name,
	prorated_flat_amt
)
as  
select
	formula_num,
	formula_body_num,
	basis_cmdty_code,
	risk_mkt_code,
	risk_trading_prd,
	pay_deduct_ind,
	cross_ref_ind,
	ref_cmdty_code,
	price_pcnt_string,
	price_pcnt_value,
	price_quote_string,
	price_rule_oid,
	line_item_contr_desc,
	line_item_invoice_desc,
	last_computed_value,
	last_computed_asof_date,
	trans_id,
	trans_id,   
	resp_trans_id,
	qp_start_date,
	qp_end_date,
	qp_election_date,
	qp_desc,
	qp_election_opt,
	qp_elected,
	qp_type,
	qp_start_date_addl_days,
	qp_end_date_addl_days,
	lib_formula_name,
	prorated_flat_amt
from dbo.aud_fb_modular_info
GO
GRANT SELECT ON  [dbo].[v_fb_modular_info_rev] TO [next_usr]
GO
