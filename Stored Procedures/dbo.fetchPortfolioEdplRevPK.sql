SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPortfolioEdplRevPK]
(
   @asof_trans_id      int,
   @port_num           int
)
as
set nocount on
declare @trans_id   int
 
select @trans_id = trans_id
from dbo.portfolio_edpl
where port_num = @port_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_date,
      asof_trans_id = @asof_trans_id,
      comp_yr_pl,
      day_pl,
      latest_pl,
      month_pl,
      port_num,
      resp_trans_id = null,
      trans_id,
      week_pl,
      year_pl
   from dbo.portfolio_edpl
   where port_num = @port_num
end
else
begin
   select top 1
      asof_date,
      asof_trans_id = @asof_trans_id,
      comp_yr_pl,
      day_pl,
      latest_pl,
      month_pl,
      port_num,
      resp_trans_id,
      trans_id,
      week_pl,
      year_pl
   from dbo.aud_portfolio_edpl
   where port_num = @port_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPortfolioEdplRevPK] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchPortfolioEdplRevPK', NULL, NULL
GO
