CREATE TABLE [dbo].[aud_commodity_alias]
(
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_alias_name] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_alias] ON [dbo].[aud_commodity_alias] ([cmdty_code], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commodity_alias_idx1] ON [dbo].[aud_commodity_alias] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_commodity_alias] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_commodity_alias] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_commodity_alias] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_commodity_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commodity_alias] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_commodity_alias', NULL, NULL
GO
