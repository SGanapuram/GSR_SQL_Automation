SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPortfolioToPortfolioEdpl]
(
   @asof_trans_id      int,
   @port_num           int
)
as
set nocount on
 
   select asof_date,
          asof_trans_id = @asof_trans_id,
          comp_yr_pl,
          day_pl,
          latest_pl,
          month_pl,
          port_num,
          resp_trans_id = NULL,
          trans_id,
          week_pl,
          year_pl
   from dbo.portfolio_edpl
   where port_num = @port_num and
         trans_id <= @asof_trans_id
   union
   select asof_date,
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
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchPortfolioToPortfolioEdpl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchPortfolioToPortfolioEdpl', NULL, NULL
GO
