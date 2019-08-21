SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPortfolioGroupRevPK]
(
   @asof_trans_id        bigint,
   @parent_port_num      int,
   @port_num             int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.portfolio_group
where parent_port_num = @parent_port_num and
      port_num = @port_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      is_link_ind,
      parent_port_num,
      port_num,
      resp_trans_id = null,
      trans_id
   from dbo.portfolio_group
   where parent_port_num = @parent_port_num and
         port_num = @port_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      is_link_ind,
      parent_port_num,
      port_num,
      resp_trans_id,
      trans_id
   from dbo.aud_portfolio_group
   where parent_port_num = @parent_port_num and
         port_num = @port_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPortfolioGroupRevPK] TO [next_usr]
GO
