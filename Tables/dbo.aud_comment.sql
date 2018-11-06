CREATE TABLE [dbo].[aud_comment]
(
[cmnt_num] [int] NOT NULL,
[tiny_cmnt] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_cmnt] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_text] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_comment] ON [dbo].[aud_comment] ([cmnt_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_comment_idx1] ON [dbo].[aud_comment] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_comment] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_comment] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_comment] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_comment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_comment', NULL, NULL
GO
