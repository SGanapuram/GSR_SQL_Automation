SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_tc_flat_benchmark_rev] 
(
	oid,
	cp_formula_oid,
	price_rule_oid,
	flat_amt,
	flat_percentage,
	app_to_flat,
	benchmark_detail_oid,
	benchmark_value,
	benchmark_percentage,
	app_to_benchmark,
	tc_value,
	from_value,
	to_value,	
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select 
    oid,
	cp_formula_oid,
	price_rule_oid,
	flat_amt,
	flat_percentage,
	app_to_flat,
	benchmark_detail_oid,
	benchmark_value,
	benchmark_percentage,
	app_to_benchmark,
	tc_value,
	from_value,
	to_value,		
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_tc_flat_benchmark
GO
GRANT SELECT ON  [dbo].[v_tc_flat_benchmark_rev] TO [next_usr]
GO
