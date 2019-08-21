CREATE TABLE [dbo].[aud_external_comment]
(
[oid] [int] NOT NULL,
[comment_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_comment] ON [dbo].[aud_external_comment] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_external_comment_idx1] ON [dbo].[aud_external_comment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_external_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_external_comment] TO [next_usr]
GO
