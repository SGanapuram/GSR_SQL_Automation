CREATE TABLE [dbo].[implied_pr_curve]
(
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
[volume_traded] [numeric] (14, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[implied_pr_curve] ADD CONSTRAINT [implied_pr_curve_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [implied_pr_curve_idx1] ON [dbo].[implied_pr_curve] ([commkt_key], [trading_prd], [price_source_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[implied_pr_curve] ADD CONSTRAINT [implied_pr_curve_fk1] FOREIGN KEY ([implied_editor_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[implied_pr_curve] ADD CONSTRAINT [implied_pr_curve_fk2] FOREIGN KEY ([implied_spread_editor_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[implied_pr_curve] ADD CONSTRAINT [implied_pr_curve_fk3] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[implied_pr_curve] ADD CONSTRAINT [implied_pr_curve_fk4] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[implied_pr_curve] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[implied_pr_curve] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[implied_pr_curve] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[implied_pr_curve] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'implied_pr_curve', NULL, NULL
GO
