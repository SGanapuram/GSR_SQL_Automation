SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxCostDrawDownHistRevPK]
(
   @asof_trans_id      bigint,
   @oid                int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.fx_cost_draw_down_hist
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cost_code,
      cost_type_code,
      draw_down_up_ind,
      from_cost_num,
      from_fx_pl_asof_date,
      fx_pl_roll_date,
      item_num,
      oid,
      order_num,
      pay_rec_ind,
      resp_trans_id = null,
      to_cost_num,
      trade_num,
      trans_id
   from dbo.fx_cost_draw_down_hist
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cost_code,
      cost_type_code,
      draw_down_up_ind,
      from_cost_num,
      from_fx_pl_asof_date,
      fx_pl_roll_date,
      item_num,
      oid,
      order_num,
      pay_rec_ind,
      resp_trans_id,
      to_cost_num,
      trade_num,
      trans_id
   from dbo.aud_fx_cost_draw_down_hist
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxCostDrawDownHistRevPK] TO [next_usr]
GO
