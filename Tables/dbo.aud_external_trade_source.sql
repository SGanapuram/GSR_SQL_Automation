CREATE TABLE [dbo].[aud_external_trade_source]
(
[oid] [int] NOT NULL,
[external_trade_src_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[external_trade_system_oid] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_source] ON [dbo].[aud_external_trade_source] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_trade_source_idx1] ON [dbo].[aud_external_trade_source] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_trade_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_trade_source] TO [next_usr]
GO
