SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_assign_trade_rev]
(
   assign_num,
   trade_num,
   order_num,
   item_num,
   ct_doc_num,
   ct_doc_type,
   acct_num,
   alloc_num,
   alloc_item_num,
   covered_amt,
   credit_exposure_oid,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   assign_num,
   trade_num,
   order_num,
   item_num,
   ct_doc_num,
   ct_doc_type,
   acct_num,
   alloc_num,
   alloc_item_num,
   covered_amt,
   credit_exposure_oid,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_assign_trade
GO
GRANT SELECT ON  [dbo].[v_assign_trade_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_assign_trade_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_assign_trade_rev', NULL, NULL
GO
