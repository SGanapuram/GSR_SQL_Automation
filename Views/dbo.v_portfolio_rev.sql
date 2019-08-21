SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_portfolio_rev]
(
   port_num,
   port_type,
   desired_pl_curr_code,
   port_short_name,
   port_full_name,
   port_class,
   port_ref_key,
   owner_init,
   cmnt_num,
   num_history_days,
   trading_entity_num ,
   port_locked,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   port_num,
   port_type,
   desired_pl_curr_code,
   port_short_name,
   port_full_name,
   port_class,
   port_ref_key,
   owner_init,
   cmnt_num,
   num_history_days,
   trading_entity_num, 
   port_locked,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_portfolio
GO
GRANT SELECT ON  [dbo].[v_portfolio_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_portfolio_rev] TO [next_usr]
GO
