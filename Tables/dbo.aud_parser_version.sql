CREATE TABLE [dbo].[aud_parser_version]
(
[oid] [int] NOT NULL,
[parser_id] [int] NOT NULL,
[delimiter] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lines_per_record] [int] NULL,
[has_header_row] [bit] NOT NULL CONSTRAINT [DF__aud_parse__has_h__2FA69406] DEFAULT ((1)),
[has_specs] [bit] NOT NULL CONSTRAINT [DF__aud_parse__has_s__309AB83F] DEFAULT ((1)),
[parser_version] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[is_active] [bit] NOT NULL CONSTRAINT [DF__aud_parse__is_ac__5C443053] DEFAULT ((1))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_version] ON [dbo].[aud_parser_version] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_version_idx1] ON [dbo].[aud_parser_version] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parser_version] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parser_version] TO [next_usr]
GO
