CREATE TABLE [dbo].[aud_parent_guarantee_comment]
(
[pg_num] [int] NOT NULL,
[cmnt_num] [int] NOT NULL,
[pg_cmnt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parent_guarantee_comment] ON [dbo].[aud_parent_guarantee_comment] ([pg_num], [cmnt_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parent_guarantee_com_idx1] ON [dbo].[aud_parent_guarantee_comment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parent_guarantee_comment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parent_guarantee_comment] TO [next_usr]
GO
