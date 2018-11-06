SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_aud_position_30]
as 
select *
from dbo.aud_position c
where exists (select 1
              from dbo.v_bcp_icts_transaction_30 t
              where c.trans_id = t.trans_id) and
      exists (select 1
              from dbo.v_bcp_icts_transaction_30 t
              where c.resp_trans_id = t.trans_id)
GO
GRANT SELECT ON  [dbo].[v_bcp_aud_position_30] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_aud_position_30] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_aud_position_30', NULL, NULL
GO
