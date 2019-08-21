SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_option_strike_rev]
(
   commkt_key,
   trading_prd,
   opt_strike_price,
   put_call_ind,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   commkt_key,
   trading_prd,
   opt_strike_price,
   put_call_ind,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_option_strike
GO
GRANT SELECT ON  [dbo].[v_option_strike_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_option_strike_rev] TO [next_usr]
GO
