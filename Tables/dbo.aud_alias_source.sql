CREATE TABLE [dbo].[aud_alias_source]
(
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_alias_source] ON [dbo].[aud_alias_source] ([alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_alias_source_idx1] ON [dbo].[aud_alias_source] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_alias_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_alias_source] TO [next_usr]
GO
