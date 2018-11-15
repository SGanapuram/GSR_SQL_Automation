CREATE TABLE [dbo].[aud_quote_marketdata_source]
(
[id] [int] NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_id] [int] NOT NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_marketdata_source] ON [dbo].[aud_quote_marketdata_source] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quote_marketdata_source_idx1] ON [dbo].[aud_quote_marketdata_source] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_quote_marketdata_source] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_quote_marketdata_source] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_quote_marketdata_source] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_quote_marketdata_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quote_marketdata_source] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_quote_marketdata_source', NULL, NULL
GO
