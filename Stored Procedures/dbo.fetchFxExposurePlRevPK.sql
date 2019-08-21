SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchFxExposurePlRevPK]
(
   @asof_trans_id      bigint,
   @exp_key_num        int,
   @exp_key_type       char(1),
   @pl_asof_date       datetime
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.fx_exposure_pl
where pl_asof_date = @pl_asof_date and
      exp_key_type = @exp_key_type and
      exp_key_num = @exp_key_num
 
if @trans_id <= @asof_trans_id
begin
   select
      asof_trans_id = @asof_trans_id,
      exp_key_num,
      exp_key_type,
      forex_open_comp_yr_pl,
      forex_open_day_pl,
      forex_open_life_pl,
      forex_open_month_pl,
      forex_open_week_pl,
      forex_open_year_pl,
      forex_unlocked_comp_yr_pl,
      forex_unlocked_day_pl,
      forex_unlocked_life_pl,
      forex_unlocked_month_pl,
      forex_unlocked_week_pl,
      forex_unlocked_year_pl,
      other_open_comp_yr_pl,
      other_open_day_pl,
      other_open_life_pl,
      other_open_month_pl,
      other_open_week_pl,
      other_open_year_pl,
      other_unlocked_comp_yr_pl,
      other_unlocked_day_pl,
      other_unlocked_life_pl,
      other_unlocked_month_pl,
      other_unlocked_week_pl,
      other_unlocked_year_pl,
      pl_asof_date,
      primary_open_comp_yr_pl,
      primary_open_day_pl,
      primary_open_life_pl,
      primary_open_month_pl,
      primary_open_week_pl,
      primary_open_year_pl,
      primary_unlocked_comp_yr_pl,
      primary_unlocked_day_pl,
      primary_unlocked_life_pl,
      primary_unlocked_month_pl,
      primary_unlocked_week_pl,
      primary_unlocked_year_pl,
      resp_trans_id = null,
      trans_id
   from dbo.fx_exposure_pl
   where pl_asof_date = @pl_asof_date and
         exp_key_type = @exp_key_type and
         exp_key_num = @exp_key_num
end
else
begin
   select top 1
      asof_trans_id = @asof_trans_id,
      exp_key_num,
      exp_key_type,
      forex_open_comp_yr_pl,
      forex_open_day_pl,
      forex_open_life_pl,
      forex_open_month_pl,
      forex_open_week_pl,
      forex_open_year_pl,
      forex_unlocked_comp_yr_pl,
      forex_unlocked_day_pl,
      forex_unlocked_life_pl,
      forex_unlocked_month_pl,
      forex_unlocked_week_pl,
      forex_unlocked_year_pl,
      other_open_comp_yr_pl,
      other_open_day_pl,
      other_open_life_pl,
      other_open_month_pl,
      other_open_week_pl,
      other_open_year_pl,
      other_unlocked_comp_yr_pl,
      other_unlocked_day_pl,
      other_unlocked_life_pl,
      other_unlocked_month_pl,
      other_unlocked_week_pl,
      other_unlocked_year_pl,
      pl_asof_date,
      primary_open_comp_yr_pl,
      primary_open_day_pl,
      primary_open_life_pl,
      primary_open_month_pl,
      primary_open_week_pl,
      primary_open_year_pl,
      primary_unlocked_comp_yr_pl,
      primary_unlocked_day_pl,
      primary_unlocked_life_pl,
      primary_unlocked_month_pl,
      primary_unlocked_week_pl,
      primary_unlocked_year_pl,
      resp_trans_id,
      trans_id
   from dbo.aud_fx_exposure_pl
   where pl_asof_date = @pl_asof_date and
         exp_key_type = @exp_key_type and
         exp_key_num = @exp_key_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchFxExposurePlRevPK] TO [next_usr]
GO
