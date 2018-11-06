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
   trans_id,
   asof_trans_id,
   resp_trans_id
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
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_trade_item_spec
GO
GRANT SELECT ON  [dbo].[v_trade_item_spec_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_trade_item_spec_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_trade_item_spec_rev', NULL, NULL
GO
