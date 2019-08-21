CREATE TABLE [dbo].[aud_portfolio_profit_loss]
(
[port_num] [int] NOT NULL,
[pl_asof_date] [datetime] NOT NULL,
[pl_calc_date] [datetime] NULL,
[pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_phys_pl] [float] NULL,
[open_hedge_pl] [float] NULL,
[closed_phys_pl] [float] NULL,
[closed_hedge_pl] [float] NULL,
[other_pl] [float] NULL,
[liq_open_phys_pl] [float] NULL,
[liq_open_hedge_pl] [float] NULL,
[liq_closed_phys_pl] [float] NULL,
[liq_closed_hedge_pl] [float] NULL,
[is_week_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_month_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_year_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_compyr_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[pass_run_detail_id] [int] NULL,
[is_official_run_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_pl_no_sec_cost] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_profit_loss] ON [dbo].[aud_portfolio_profit_loss] ([port_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_portfolio_profit_los_idx1] ON [dbo].[aud_portfolio_profit_loss] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_profit_loss] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_profit_loss] TO [next_usr]
GO
