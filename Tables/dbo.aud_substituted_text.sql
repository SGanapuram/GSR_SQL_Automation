CREATE TABLE [dbo].[aud_substituted_text]
(
[alias_source_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[keyword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[substituted_string] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_substituted_text_idx] ON [dbo].[aud_substituted_text] ([alias_source_name], [keyword], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_substituted_text_idx1] ON [dbo].[aud_substituted_text] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_substituted_text] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_substituted_text] TO [next_usr]
GO
