CREATE TABLE [dbo].[aud_market_value]
(
[id] [int] NOT NULL,
[market_value] [decimal] (20, 8) NOT NULL,
[marketdata_supplier_id] [int] NOT NULL,
[priced_quote_period_id] [int] NOT NULL,
[received_date_time] [datetime] NOT NULL,
[settlement_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_value] ON [dbo].[aud_market_value] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_value_idx1] ON [dbo].[aud_market_value] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_market_value] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_market_value] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_market_value] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_market_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_value] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_market_value', NULL, NULL
GO
