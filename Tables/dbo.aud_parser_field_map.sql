CREATE TABLE [dbo].[aud_parser_field_map]
(
[id] [int] NOT NULL,
[map_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[map_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parser_field_id] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[default_map] [bit] NOT NULL CONSTRAINT [DF__aud_parse__defau__63E5521B] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_field_map] ON [dbo].[aud_parser_field_map] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_field_map_idx1] ON [dbo].[aud_parser_field_map] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_parser_field_map] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_parser_field_map] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_parser_field_map] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_parser_field_map] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parser_field_map] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_parser_field_map', NULL, NULL
GO
