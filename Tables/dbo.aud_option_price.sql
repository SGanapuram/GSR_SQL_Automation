CREATE TABLE [dbo].[aud_option_price]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_strike_price] [float] NOT NULL,
[put_call_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[opt_price_quote_date] [datetime] NOT NULL,
[low_bid_price] [float] NULL,
[high_asked_price] [float] NULL,
[avg_closed_price] [float] NULL,
[open_interest] [float] NULL,
[vol_traded] [float] NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility] [float] NULL,
[low_bid_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[high_asked_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_closed_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[volatility_creation_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_option_price] ON [dbo].[aud_option_price] ([commkt_key], [price_source_code], [trading_prd], [opt_strike_price], [put_call_ind], [opt_price_quote_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_option_price_idx1] ON [dbo].[aud_option_price] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_option_price] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_option_price] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_option_price] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_option_price] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_option_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_option_price', NULL, NULL
GO
