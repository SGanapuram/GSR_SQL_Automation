SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchExternalTradeRevPK]
(
   @asof_trans_id      int,
   @oid                int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.external_trade
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      entry_date,
      ext_pos_num,
      external_comment_oid,
      external_trade_source_oid,
      external_trade_state_oid,
      external_trade_status_oid,
      external_trade_system_oid,
      inhouse_port_num,
      item_num,
      oid,
      order_num,
      port_num,
      resp_trans_id = null,
      sequence,
      trade_num,
      trans_id
   from dbo.external_trade
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      entry_date,
      ext_pos_num,
      external_comment_oid,
      external_trade_source_oid,
      external_trade_state_oid,
      external_trade_status_oid,
      external_trade_system_oid,
      inhouse_port_num,
      item_num,
      oid,
      order_num,
      port_num,
      resp_trans_id,
      sequence,
      trade_num,
      trans_id
   from dbo.aud_external_trade
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchExternalTradeRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchExternalTradeRevPK', NULL, NULL
GO
