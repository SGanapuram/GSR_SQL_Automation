CREATE TABLE [dbo].[aud_parser]
(
[id] [int] NOT NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parser_type_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[is_active] [bit] NOT NULL CONSTRAINT [df_aud_parser_is_active] DEFAULT ((1))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser] ON [dbo].[aud_parser] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_idx1] ON [dbo].[aud_parser] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parser] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parser] TO [next_usr]
GO
