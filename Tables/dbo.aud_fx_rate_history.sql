CREATE TABLE [dbo].[aud_fx_rate_history]
(
[cost_num] [int] NOT NULL,
[rate_from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_multi_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fx_asof_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[fx_exp_num] [int] NOT NULL,
[fx_rate] [numeric] (20, 8) NULL,
[fx_spot_rate] [numeric] (20, 8) NULL,
[day_cost_amt] [numeric] (20, 8) NULL,
[prev_day_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_day_cost_amt] [numeric] (20, 8) NULL,
[day_fx_pl] [numeric] (20, 8) NULL,
[prev_week_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_week_cost_amt] [numeric] (20, 8) NULL,
[week_fx_pl] [numeric] (20, 8) NULL,
[prev_month_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_month_cost_amt] [numeric] (20, 8) NULL,
[month_fx_pl] [numeric] (20, 8) NULL,
[prev_year_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_year_cost_amt] [numeric] (20, 8) NULL,
[year_fx_pl] [numeric] (20, 8) NULL,
[prev_comp_yr_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_comp_yr_cost_amt] [numeric] (20, 8) NULL,
[comp_yr_fx_pl] [numeric] (20, 8) NULL,
[prev_life_initial_fx_rate] [numeric] (20, 8) NULL,
[prev_life_cost_amt] [numeric] (20, 8) NULL,
[life_fx_pl] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_rate_history] ON [dbo].[aud_fx_rate_history] ([cost_num], [fx_asof_date], [real_port_num], [fx_exp_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_rate_history_idx1] ON [dbo].[aud_fx_rate_history] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_fx_rate_history] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_fx_rate_history] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_fx_rate_history] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_fx_rate_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_rate_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_fx_rate_history', NULL, NULL
GO
