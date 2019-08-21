SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchRcAssignTradeRevPK]
(
   @asof_trans_id      bigint,
   @assign_num         int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.rc_assign_trade
where assign_num = @assign_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      assign_num,
      cargo_value,
      item_num,
      order_num,
      resp_trans_id = null,
      risk_cover_num,
      trade_num,
      trans_id
   from dbo.rc_assign_trade
   where assign_num = @assign_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      assign_num,
      cargo_value,
      item_num,
      order_num,
      resp_trans_id,
      risk_cover_num,
      trade_num,
      trans_id
   from dbo.aud_rc_assign_trade
   where assign_num = @assign_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchRcAssignTradeRevPK] TO [next_usr]
GO
