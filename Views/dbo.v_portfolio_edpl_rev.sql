SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_portfolio_edpl_rev]
(
   port_num,
   latest_pl,
   day_pl,
   week_pl,
   month_pl,
   year_pl,
   comp_yr_pl,
   asof_date,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   port_num,
   latest_pl,
   day_pl,
   week_pl,
   month_pl,
   year_pl,
   comp_yr_pl,
   asof_date,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_portfolio_edpl
GO
GRANT SELECT ON  [dbo].[v_portfolio_edpl_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_portfolio_edpl_rev] TO [next_usr]
GO
