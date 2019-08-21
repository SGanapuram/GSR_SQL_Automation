CREATE TABLE [dbo].[aud_priced_quote_period]
(
[id] [int] NOT NULL,
[end_pricing_date] [datetime] NULL,
[end_trading_date] [datetime] NULL,
[quote_id] [int] NULL,
[quote_period_desc_id] [int] NULL,
[symbol] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_priced_quote_period] ON [dbo].[aud_priced_quote_period] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_priced_quote_period_idx1] ON [dbo].[aud_priced_quote_period] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_priced_quote_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_priced_quote_period] TO [next_usr]
GO
