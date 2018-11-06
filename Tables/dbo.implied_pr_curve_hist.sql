CREATE TABLE [dbo].[implied_pr_curve_hist]
(
[date] [datetime] NOT NULL,
[commkt_key] [int] NOT NULL,
[close_column] [numeric] (14, 4) NULL,
[high] [numeric] (14, 4) NULL,
[implied] [numeric] (14, 4) NULL,
[implied_change] [numeric] (14, 4) NULL,
[implied_editor_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[implied_spread] [numeric] (14, 4) NULL,
[implied_spread_editor_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last] [numeric] (14, 4) NULL,
[low] [numeric] (14, 4) NULL,
[net_change] [numeric] (14, 4) NULL,
[net_spread] [numeric] (14, 4) NULL,
[oid] [int] NOT NULL,
[open_interest] [numeric] (14, 4) NULL,
[open_price] [numeric] (14, 4) NULL,
[previous_close] [numeric] (14, 4) NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spread_close] [numeric] (14, 4) NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[volume_traded] [numeric] (14, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[implied_pr_curve_hist] ADD CONSTRAINT [implied_pr_curve_hist_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [implied_pr_curve_hist_idx1] ON [dbo].[implied_pr_curve_hist] ([commkt_key], [trading_prd], [price_source_code], [date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [implied_pr_curve_hist_idx2] ON [dbo].[implied_pr_curve_hist] ([date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[implied_pr_curve_hist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[implied_pr_curve_hist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[implied_pr_curve_hist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[implied_pr_curve_hist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'implied_pr_curve_hist', NULL, NULL
GO
