SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_linking_rev]
(
   oid,
   fx_link_rate,
   fx_rate_m_d_ind,
   from_curr_code,
   to_curr_code,
   need_rate_computation,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   fx_link_rate,
   fx_rate_m_d_ind,
   from_curr_code,
   to_curr_code,
   need_rate_computation,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_linking
GO
GRANT SELECT ON  [dbo].[v_fx_linking_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_linking_rev] TO [next_usr]
GO
