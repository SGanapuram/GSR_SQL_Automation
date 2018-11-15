SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_formula_body_trigger_rev]
(
	formula_num,
	formula_body_num,
	trigger_num,
	trigger_qty,
	trigger_date,
	trigger_price,
	trigger_price_curr_code,
	trigger_price_uom_code,
	trigger_qty_uom_code,
	input_qty,
	input_qty_uom_code,
	input_lock_ind,
	parcel_num,
	trans_id,
	asof_trans_id,
	resp_trans_id
)
as
select
	formula_num,
	formula_body_num,
	trigger_num,
	trigger_qty,
	trigger_date,
	trigger_price,
	trigger_price_curr_code,
	trigger_price_uom_code,
	trigger_qty_uom_code,
	input_qty,
	input_qty_uom_code,
	input_lock_ind,
	parcel_num,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_formula_body_trigger                                                      
GO
GRANT SELECT ON  [dbo].[v_formula_body_trigger_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_formula_body_trigger_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_formula_body_trigger_rev', NULL, NULL
GO
