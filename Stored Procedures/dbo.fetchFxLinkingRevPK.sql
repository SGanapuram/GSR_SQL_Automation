SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxLinkingRevPK]
(
   @asof_trans_id      bigint,
   @oid                int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.fx_linking
where oid = @oid
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      from_curr_code,
      fx_link_rate,
      fx_rate_m_d_ind,
      need_rate_computation,
      oid,
      resp_trans_id = null,
      to_curr_code,
      trans_id
   from dbo.fx_linking
   where oid = @oid
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      from_curr_code,
      fx_link_rate,
      fx_rate_m_d_ind,
      need_rate_computation,
      oid,
      resp_trans_id,
      to_curr_code,
      trans_id
   from dbo.aud_fx_linking
   where oid = @oid and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxLinkingRevPK] TO [next_usr]
GO
