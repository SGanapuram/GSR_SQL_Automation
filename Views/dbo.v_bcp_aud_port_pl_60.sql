SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_bcp_aud_port_pl_60]
as 
select *
from dbo.aud_portfolio_profit_loss c
where exists (select 1
              from dbo.v_bcp_icts_transaction_60 t
              where c.trans_id = t.trans_id) and
      exists (select 1
              from dbo.v_bcp_icts_transaction_60 t
              where c.resp_trans_id = t.trans_id)
GO
GRANT SELECT ON  [dbo].[v_bcp_aud_port_pl_60] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_bcp_aud_port_pl_60] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_aud_port_pl_60', NULL, NULL
GO
