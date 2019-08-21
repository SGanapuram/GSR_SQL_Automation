CREATE TABLE [dbo].[aud_user_user_group]
(
[user_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_user_group_idx1] ON [dbo].[aud_user_user_group] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_user_group] ON [dbo].[aud_user_user_group] ([user_group_code], [user_init], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_user_user_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_user_user_group] TO [next_usr]
GO
