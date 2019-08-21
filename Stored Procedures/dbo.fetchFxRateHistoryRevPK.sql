SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxRateHistoryRevPK]
(
   @asof_trans_id      bigint,
   @cost_num           int,
   @fx_asof_date       datetime,
   @fx_exp_num         int,
   @real_port_num      int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.fx_rate_history
where cost_num = @cost_num and
      fx_asof_date = @fx_asof_date and
      real_port_num = @real_port_num and
      fx_exp_num = @fx_exp_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      comp_yr_fx_pl,
      cost_num,
      day_cost_amt,
      day_fx_pl,
      fx_asof_date,
      fx_exp_num,
      fx_rate,
      fx_spot_rate,
      life_fx_pl,
      month_fx_pl,
      prev_comp_yr_cost_amt,
      prev_comp_yr_initial_fx_rate,
      prev_day_cost_amt,
      prev_day_initial_fx_rate,
      prev_life_cost_amt,
      prev_life_initial_fx_rate,
      prev_month_cost_amt,
      prev_month_initial_fx_rate,
      prev_week_cost_amt,
      prev_week_initial_fx_rate,
      prev_year_cost_amt,
      prev_year_initial_fx_rate,
      rate_from_curr_code,
      rate_multi_div_ind,
      rate_to_curr_code,
      real_port_num,
      resp_trans_id = null,
      trans_id,
      week_fx_pl,
      year_fx_pl
   from dbo.fx_rate_history
   where cost_num = @cost_num and
         fx_asof_date = @fx_asof_date and
         real_port_num = @real_port_num and
         fx_exp_num = @fx_exp_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      comp_yr_fx_pl,
      cost_num,
      day_cost_amt,
      day_fx_pl,
      fx_asof_date,
      fx_exp_num,
      fx_rate,
      fx_spot_rate,
      life_fx_pl,
      month_fx_pl,
      prev_comp_yr_cost_amt,
      prev_comp_yr_initial_fx_rate,
      prev_day_cost_amt,
      prev_day_initial_fx_rate,
      prev_life_cost_amt,
      prev_life_initial_fx_rate,
      prev_month_cost_amt,
      prev_month_initial_fx_rate,
      prev_week_cost_amt,
      prev_week_initial_fx_rate,
      prev_year_cost_amt,
      prev_year_initial_fx_rate,
      rate_from_curr_code,
      rate_multi_div_ind,
      rate_to_curr_code,
      real_port_num,
      resp_trans_id,
      trans_id,
      week_fx_pl,
      year_fx_pl
   from dbo.aud_fx_rate_history
   where cost_num = @cost_num and
         fx_asof_date = @fx_asof_date and
         real_port_num = @real_port_num and
         fx_exp_num = @fx_exp_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxRateHistoryRevPK] TO [next_usr]
GO
