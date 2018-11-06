SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_assign_trade] 
(
   trade_num,
   order_num,
   item_num,
   ct_doc_num
)
as
select
   trade_num,
   order_num,
   item_num,
   ct_doc_num
from dbo.assign_trade with (nolock)
where ct_doc_type = 'LC' and 
      alloc_num is null

GO
GRANT SELECT ON  [dbo].[v_TS_assign_trade] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_assign_trade] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_assign_trade', NULL, NULL
GO
