SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_rc_assign_trade_rev]
(
   assign_num,
   risk_cover_num,
   trade_num,
   order_num,
   item_num,
   cargo_value,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   assign_num,
   risk_cover_num,
   trade_num,
   order_num,
   item_num,
   cargo_value,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_rc_assign_trade
GO
GRANT SELECT ON  [dbo].[v_rc_assign_trade_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_rc_assign_trade_rev] TO [next_usr]
GO
