SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchPortfolioProfitLossRevPK]
(
   @asof_trans_id      bigint,
   @pl_asof_date       datetime,
   @port_num           int
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.portfolio_profit_loss
where port_num = @port_num and
      pl_asof_date = @pl_asof_date
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      closed_hedge_pl,
      closed_phys_pl,
      is_compyr_end_ind,
      is_month_end_ind,
      is_official_run_ind,
      is_week_end_ind,
      is_year_end_ind,
      liq_closed_hedge_pl,
      liq_closed_phys_pl,
      liq_open_hedge_pl,
      liq_open_phys_pl,
      open_hedge_pl,
      open_phys_pl,
      other_pl,
      pass_run_detail_id,
      pl_asof_date,
      pl_calc_date,
      pl_curr_code,
      port_num,
      resp_trans_id = null,
      total_pl_no_sec_cost,
      trans_id
   from dbo.portfolio_profit_loss
   where port_num = @port_num and
         pl_asof_date = @pl_asof_date
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      closed_hedge_pl,
      closed_phys_pl,
      is_compyr_end_ind,
      is_month_end_ind,
      is_official_run_ind,
      is_week_end_ind,
      is_year_end_ind,
      liq_closed_hedge_pl,
      liq_closed_phys_pl,
      liq_open_hedge_pl,
      liq_open_phys_pl,
      open_hedge_pl,
      open_phys_pl,
      other_pl,
      pass_run_detail_id,
      pl_asof_date,
      pl_calc_date,
      pl_curr_code,
      port_num,
      resp_trans_id,
      total_pl_no_sec_cost,
      trans_id
   from dbo.aud_portfolio_profit_loss
   where port_num = @port_num and
         pl_asof_date = @pl_asof_date and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchPortfolioProfitLossRevPK] TO [next_usr]
GO
