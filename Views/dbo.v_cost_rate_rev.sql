SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_cost_rate_rev]
(
   oid,
   cost_num,
   rate,
   rate_curr_code,
   rate_uom_code,
   effective_date,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   cost_num,
   rate,
   rate_curr_code,
   rate_uom_code,
   effective_date,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_cost_rate
GO
GRANT SELECT ON  [dbo].[v_cost_rate_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_cost_rate_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_cost_rate_rev', NULL, NULL
GO
