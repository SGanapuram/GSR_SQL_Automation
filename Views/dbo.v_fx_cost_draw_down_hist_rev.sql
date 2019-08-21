SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_cost_draw_down_hist_rev]
(
   oid,
   trade_num,
   order_num,
   item_num,
   from_fx_pl_asof_date,
   cost_code,
   pay_rec_ind,
   cost_type_code,
   from_cost_num,
   to_cost_num,
   draw_down_up_ind,
   fx_pl_roll_date,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   oid,
   trade_num,
   order_num,
   item_num,
   from_fx_pl_asof_date,
   cost_code,
   pay_rec_ind,
   cost_type_code,
   from_cost_num,
   to_cost_num,
   draw_down_up_ind,
   fx_pl_roll_date,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_cost_draw_down_hist
GO
GRANT SELECT ON  [dbo].[v_fx_cost_draw_down_hist_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_cost_draw_down_hist_rev] TO [next_usr]
GO
