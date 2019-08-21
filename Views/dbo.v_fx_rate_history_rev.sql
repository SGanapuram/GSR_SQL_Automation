SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_fx_rate_history_rev]
(
   cost_num,
   rate_from_curr_code,
   rate_to_curr_code,
   rate_multi_div_ind,
   fx_asof_date,
   real_port_num,
   fx_exp_num,
   fx_rate,
   fx_spot_rate,
   day_cost_amt,
   prev_day_initial_fx_rate,
   prev_day_cost_amt,
   day_fx_pl,
   prev_week_initial_fx_rate,
   prev_week_cost_amt,
   week_fx_pl,
   prev_month_initial_fx_rate,
   prev_month_cost_amt,
   month_fx_pl,
   prev_year_initial_fx_rate,
   prev_year_cost_amt,
   year_fx_pl,
   prev_comp_yr_initial_fx_rate,
   prev_comp_yr_cost_amt,
   comp_yr_fx_pl,
   prev_life_initial_fx_rate,
   prev_life_cost_amt,
   life_fx_pl,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   cost_num,
   rate_from_curr_code,
   rate_to_curr_code,
   rate_multi_div_ind,
   fx_asof_date,
   real_port_num,
   fx_exp_num,
   fx_rate,
   fx_spot_rate,
   day_cost_amt,
   prev_day_initial_fx_rate,
   prev_day_cost_amt,
   day_fx_pl,
   prev_week_initial_fx_rate,
   prev_week_cost_amt,
   week_fx_pl,
   prev_month_initial_fx_rate,
   prev_month_cost_amt,
   month_fx_pl,
   prev_year_initial_fx_rate,
   prev_year_cost_amt,
   year_fx_pl,
   prev_comp_yr_initial_fx_rate,
   prev_comp_yr_cost_amt,
   comp_yr_fx_pl,
   prev_life_initial_fx_rate,
   prev_life_cost_amt,
   life_fx_pl,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_fx_rate_history
GO
GRANT SELECT ON  [dbo].[v_fx_rate_history_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_rate_history_rev] TO [next_usr]
GO
