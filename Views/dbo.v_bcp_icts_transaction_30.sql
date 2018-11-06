SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_icts_transaction_30] 
as
select *
from dbo.icts_transaction
where tran_date >= dateadd(day, -30, getdate()) or
      trans_id = 1
GO
GRANT SELECT ON  [dbo].[v_bcp_icts_transaction_30] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_icts_transaction_30] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_bcp_icts_transaction_30] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_icts_transaction_30', NULL, NULL
GO
