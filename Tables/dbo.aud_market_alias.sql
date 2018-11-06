CREATE TABLE [dbo].[aud_market_alias]
(
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_alias_name] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_alias] ON [dbo].[aud_market_alias] ([mkt_code], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_market_alias_idx1] ON [dbo].[aud_market_alias] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_market_alias] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_market_alias] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_market_alias] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_market_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_market_alias] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_market_alias', NULL, NULL
GO
