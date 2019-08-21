SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_qp_option_rev] 
(
	oid,
	cp_formula_oid,
	price_rule_oid,
	quote_index,
	commkt_key,
	quote_source_code,
	quote_point,
	formula_string,
	trading_prd,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	cp_formula_oid,
	price_rule_oid,
	quote_index,
	commkt_key,
	quote_source_code,
	quote_point,
	formula_string,
	trading_prd,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_qp_option
GO
GRANT SELECT ON  [dbo].[v_qp_option_rev] TO [next_usr]
GO
