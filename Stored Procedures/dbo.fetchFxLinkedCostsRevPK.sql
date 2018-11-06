SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxLinkedCostsRevPK]
(
   @asof_trans_id      int,
   @cost_num           int,
   @fx_link_oid        int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.fx_linked_costs
where fx_link_oid = @fx_link_oid and
      cost_num = @cost_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cost_num,
      curr_cost_ind,
      fx_link_oid,
      resp_trans_id = null,
      trans_id
   from dbo.fx_linked_costs
   where fx_link_oid = @fx_link_oid and
         cost_num = @cost_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cost_num,
      curr_cost_ind,
      fx_link_oid,
      resp_trans_id,
      trans_id
   from dbo.aud_fx_linked_costs
   where fx_link_oid = @fx_link_oid and
         cost_num = @cost_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxLinkedCostsRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchFxLinkedCostsRevPK', NULL, NULL
GO
