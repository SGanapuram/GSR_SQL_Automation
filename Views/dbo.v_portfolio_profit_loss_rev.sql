SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_portfolio_profit_loss_rev]
(
   port_num,
   pl_asof_date,
   pl_calc_date,
   pl_curr_code,
   open_phys_pl,
   open_hedge_pl,
   closed_phys_pl,
   closed_hedge_pl,
   other_pl,
   liq_open_phys_pl,
   liq_open_hedge_pl,
   liq_closed_phys_pl,
   liq_closed_hedge_pl,
   is_week_end_ind,
   is_month_end_ind,
   is_year_end_ind,
   is_compyr_end_ind,
   pass_run_detail_id,
   is_official_run_ind,
   total_pl_no_sec_cost,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   port_num,
   pl_asof_date,
   pl_calc_date,
   pl_curr_code,
   open_phys_pl,
   open_hedge_pl,
   closed_phys_pl,
   closed_hedge_pl,
   other_pl,
   liq_open_phys_pl,
   liq_open_hedge_pl,
   liq_closed_phys_pl,
   liq_closed_hedge_pl,
   is_week_end_ind,
   is_month_end_ind,
   is_year_end_ind,
   is_compyr_end_ind,
   pass_run_detail_id,
   is_official_run_ind,
   total_pl_no_sec_cost,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_portfolio_profit_loss
GO
GRANT SELECT ON  [dbo].[v_portfolio_profit_loss_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_portfolio_profit_loss_rev] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_portfolio_profit_loss_rev', NULL, NULL
GO
