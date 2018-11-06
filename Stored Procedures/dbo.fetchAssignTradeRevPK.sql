SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAssignTradeRevPK]
(
   @asof_trans_id      int,
   @assign_num         int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.assign_trade
where assign_num = @assign_num
 
if @trans_id <= @asof_trans_id
begin
   select
      acct_num,
      alloc_item_num,
      alloc_num,
      asof_trans_id = @asof_trans_id,
      assign_num,
      covered_amt,
      credit_exposure_oid,
      ct_doc_num,
      ct_doc_type,
      item_num,
      order_num,
      resp_trans_id = null,
      trade_num,
      trans_id
   from dbo.assign_trade
   where assign_num = @assign_num
end
else
begin
   select top 1
      acct_num,
      alloc_item_num,
      alloc_num,
      asof_trans_id = @asof_trans_id,
      assign_num,
      covered_amt,
      credit_exposure_oid,
      ct_doc_num,
      ct_doc_type,
      item_num,
      order_num,
      resp_trans_id,
      trade_num,
      trans_id
   from dbo.aud_assign_trade
   where assign_num = @assign_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchAssignTradeRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchAssignTradeRevPK', NULL, NULL
GO
