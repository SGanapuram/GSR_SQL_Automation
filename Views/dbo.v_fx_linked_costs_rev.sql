SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_linked_costs_rev]
(
   fx_link_oid,
   cost_num,
   curr_cost_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   fx_link_oid,
   cost_num,
   curr_cost_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_linked_costs
GO
GRANT SELECT ON  [dbo].[v_fx_linked_costs_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_linked_costs_rev] TO [next_usr]
GO
