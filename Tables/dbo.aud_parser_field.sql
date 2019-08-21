CREATE TABLE [dbo].[aud_parser_field]
(
[id] [int] NOT NULL,
[conversion_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_index] [int] NULL,
[end_index] [int] NULL,
[field_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field_number] [int] NULL,
[field_numbers] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[line_number] [int] NULL,
[parser_format] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parser_version_id] [int] NOT NULL,
[regex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[result_concatenator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[static_field_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[format_string] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_mandatory] [bit] NOT NULL CONSTRAINT [df_aud_parser_field_is_mandatory] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_field] ON [dbo].[aud_parser_field] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parser_field_idx1] ON [dbo].[aud_parser_field] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parser_field] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parser_field] TO [next_usr]
GO
