SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPortfolioRevPK]
(
   @asof_trans_id      bigint,
   @port_num           int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.portfolio
where port_num = @port_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      cmnt_num,
      desired_pl_curr_code,
      num_history_days,
      owner_init,
      port_class,
      port_full_name,
      port_locked,
      port_num,
      port_ref_key,
      port_short_name,
      port_type,
      resp_trans_id = null,
      trading_entity_num,
      trans_id
   from dbo.portfolio
   where port_num = @port_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      cmnt_num,
      desired_pl_curr_code,
      num_history_days,
      owner_init,
      port_class,
      port_full_name,
      port_locked,
      port_num,
      port_ref_key,
      port_short_name,
      port_type,
      resp_trans_id,
      trading_entity_num,
      trans_id
   from dbo.aud_portfolio
   where port_num = @port_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPortfolioRevPK] TO [next_usr]
GO
