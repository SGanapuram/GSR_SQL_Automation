CREATE TABLE [dbo].[aud_commkt_source_alias]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[commkt_source_alias_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_format_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_source_alias] ON [dbo].[aud_commkt_source_alias] ([commkt_key], [price_source_code], [alias_source_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_commkt_source_alias_idx1] ON [dbo].[aud_commkt_source_alias] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_commkt_source_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_commkt_source_alias] TO [next_usr]
GO
