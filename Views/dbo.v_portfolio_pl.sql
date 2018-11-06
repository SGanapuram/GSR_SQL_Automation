SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_portfolio_pl]
(
   closed_hedge_pl,
   closed_phys_pl,
   liq_closed_hedge_pl,
   liq_closed_phys_pl,
   open_hedge_pl,
   open_phys_pl,
   pl_asof_date,
   port_num
)
as
select
   closed_hedge_pl,
   closed_phys_pl,
   liq_closed_hedge_pl,
   liq_closed_phys_pl,
   open_hedge_pl,
   open_phys_pl,
   pl_asof_date,
   port_num
from dbo.portfolio_profit_loss
GO
GRANT SELECT ON  [dbo].[v_portfolio_pl] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_portfolio_pl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_portfolio_pl', NULL, NULL
GO
