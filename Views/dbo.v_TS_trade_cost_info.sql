SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_trade_cost_info] 
( 
   cost_owner_key6,
   cost_owner_key7,
   cost_owner_key8,
   principle_cost_amt
)
as
select 
   cost_owner_key6,
   cost_owner_key7,
   cost_owner_key8,
   SUM(cost_amt * (case when cost_pay_rec_ind = 'P'
                           then -1.0
                        else 1.0
                   end))
from dbo.cost
where isnull(cost_status, 'CLOSED') <> 'CLOSED' and
      cost_prim_sec_ind = 'P'
group by cost_owner_key6,
         cost_owner_key7,
         cost_owner_key8
GO
GRANT SELECT ON  [dbo].[v_TS_trade_cost_info] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_trade_cost_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_TS_trade_cost_info', NULL, NULL
GO
