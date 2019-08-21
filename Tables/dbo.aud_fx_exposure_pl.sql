CREATE TABLE [dbo].[aud_fx_exposure_pl]
(
[pl_asof_date] [datetime] NOT NULL,
[exp_key_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exp_key_num] [int] NOT NULL,
[primary_open_day_pl] [numeric] (20, 8) NULL,
[primary_unlocked_day_pl] [numeric] (20, 8) NULL,
[primary_open_week_pl] [numeric] (20, 8) NULL,
[primary_unlocked_week_pl] [numeric] (20, 8) NULL,
[primary_open_month_pl] [numeric] (20, 8) NULL,
[primary_unlocked_month_pl] [numeric] (20, 8) NULL,
[primary_open_year_pl] [numeric] (20, 8) NULL,
[primary_unlocked_year_pl] [numeric] (20, 8) NULL,
[primary_open_comp_yr_pl] [numeric] (20, 8) NULL,
[primary_unlocked_comp_yr_pl] [numeric] (20, 8) NULL,
[primary_open_life_pl] [numeric] (20, 8) NULL,
[primary_unlocked_life_pl] [numeric] (20, 8) NULL,
[forex_open_day_pl] [numeric] (20, 8) NULL,
[forex_unlocked_day_pl] [numeric] (20, 8) NULL,
[forex_open_week_pl] [numeric] (20, 8) NULL,
[forex_unlocked_week_pl] [numeric] (20, 8) NULL,
[forex_open_month_pl] [numeric] (20, 8) NULL,
[forex_unlocked_month_pl] [numeric] (20, 8) NULL,
[forex_open_year_pl] [numeric] (20, 8) NULL,
[forex_unlocked_year_pl] [numeric] (20, 8) NULL,
[forex_open_comp_yr_pl] [numeric] (20, 8) NULL,
[forex_unlocked_comp_yr_pl] [numeric] (20, 8) NULL,
[forex_open_life_pl] [numeric] (20, 8) NULL,
[forex_unlocked_life_pl] [numeric] (20, 8) NULL,
[other_open_day_pl] [numeric] (20, 8) NULL,
[other_unlocked_day_pl] [numeric] (20, 8) NULL,
[other_open_week_pl] [numeric] (20, 8) NULL,
[other_unlocked_week_pl] [numeric] (20, 8) NULL,
[other_open_month_pl] [numeric] (20, 8) NULL,
[other_unlocked_month_pl] [numeric] (20, 8) NULL,
[other_open_year_pl] [numeric] (20, 8) NULL,
[other_unlocked_year_pl] [numeric] (20, 8) NULL,
[other_open_comp_yr_pl] [numeric] (20, 8) NULL,
[other_unlocked_comp_yr_pl] [numeric] (20, 8) NULL,
[other_open_life_pl] [numeric] (20, 8) NULL,
[other_unlocked_life_pl] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_pl] ON [dbo].[aud_fx_exposure_pl] ([pl_asof_date], [exp_key_type], [exp_key_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_pl_idx1] ON [dbo].[aud_fx_exposure_pl] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fx_exposure_pl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_exposure_pl] TO [next_usr]
GO
