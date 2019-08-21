SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_trade_item_spec_rev]
(
   trade_num,
   order_num,
   item_num,
   spec_code,
   spec_min_val,
   spec_max_val,
   spec_typical_val,
   spec_test_code,
   cmnt_num,
   spec_provisional_val,
   splitting_limit,
   equiv_pay_deduct_ind,
   equiv_del_cmdty_code,
   equiv_del_mkt_code,
   trans_id,
   asof_trans_id,
   resp_trans_id,
   use_in_formula_ind,
   use_in_cost_ind,
   equiv_del_period
)
as
select
   trade_num,
   order_num,
   item_num,
   spec_code,
   spec_min_val,
   spec_max_val,
   spec_typical_val,
   spec_test_code,
   cmnt_num,
   spec_provisional_val,
   splitting_limit,
   equiv_pay_deduct_ind,
   equiv_del_cmdty_code,
   equiv_del_mkt_code,
   trans_id,
   trans_id,
   resp_trans_id,
   use_in_formula_ind,
   use_in_cost_ind,
   equiv_del_period
from dbo.aud_trade_item_spec
GO
GRANT SELECT ON  [dbo].[v_trade_item_spec_rev] TO [next_usr]
GO
