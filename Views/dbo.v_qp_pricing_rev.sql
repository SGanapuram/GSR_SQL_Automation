SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_qp_pricing_rev] 
(
	oid,
	qp_option_oid,
	pricing_option_ind,
	min_qty,
	min_qty_uom_code,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select oid,
	qp_option_oid,
	pricing_option_ind,
	min_qty,
	min_qty_uom_code,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_qp_pricing
GO
GRANT SELECT ON  [dbo].[v_qp_pricing_rev] TO [next_usr]
GO
