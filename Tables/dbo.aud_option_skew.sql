CREATE TABLE [dbo].[aud_option_skew]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_strike_skew] [numeric] (20, 8) NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_vol_quote_date] [datetime] NOT NULL,
[volatility] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_option_skew] ON [dbo].[aud_option_skew] ([commkt_key], [price_source_code], [trading_prd], [opt_strike_skew], [put_call_ind], [opt_vol_quote_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_option_skew_idx1] ON [dbo].[aud_option_skew] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_option_skew] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_option_skew] TO [next_usr]
GO
