CREATE TABLE [dbo].[aud_portfolio_edpl]
(
[port_num] [int] NOT NULL,
[latest_pl] [numeric] (20, 8) NULL,
[day_pl] [numeric] (20, 8) NULL,
[week_pl] [numeric] (20, 8) NULL,
[month_pl] [numeric] (20, 8) NULL,
[year_pl] [numeric] (20, 8) NULL,
[comp_yr_pl] [numeric] (20, 8) NULL,
[asof_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_portfolio_edpl] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_edpl] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_portfolio_edpl] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_portfolio_edpl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_portfolio_edpl] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_portfolio_edpl', NULL, NULL
GO
