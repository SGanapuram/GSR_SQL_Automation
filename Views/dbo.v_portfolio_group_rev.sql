SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_portfolio_group_rev]
(
   parent_port_num,
   port_num,
   is_link_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   parent_port_num,
   port_num,
   is_link_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_portfolio_group
GO
GRANT SELECT ON  [dbo].[v_portfolio_group_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_portfolio_group_rev] TO [next_usr]
GO
