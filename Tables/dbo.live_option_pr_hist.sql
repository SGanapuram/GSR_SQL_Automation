CREATE TABLE [dbo].[live_option_pr_hist]
(
[commkt_key] [int] NOT NULL,
[close_column] [numeric] (14, 4) NULL,
[date] [datetime] NOT NULL,
[high] [numeric] (14, 4) NULL,
[last] [numeric] (14, 4) NULL,
[low] [numeric] (14, 4) NULL,
[net_change] [numeric] (14, 4) NULL,
[oid] [int] NOT NULL,
[open_interest] [numeric] (14, 4) NULL,
[open_price] [numeric] (14, 4) NULL,
[opt_strike_price] [numeric] (14, 4) NOT NULL,
[previous_close] [numeric] (14, 4) NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[volume_traded] [numeric] (14, 4) NULL,
[volatility] [numeric] (14, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[live_option_pr_hist] ADD CONSTRAINT [live_option_pr_hist_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [live_option_pr_hist_idx1] ON [dbo].[live_option_pr_hist] ([commkt_key], [trading_prd], [price_source_code], [put_call_ind], [opt_strike_price], [date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[live_option_pr_hist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[live_option_pr_hist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[live_option_pr_hist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[live_option_pr_hist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'live_option_pr_hist', NULL, NULL
GO
