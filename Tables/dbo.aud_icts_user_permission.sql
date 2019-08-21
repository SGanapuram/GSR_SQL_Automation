CREATE TABLE [dbo].[aud_icts_user_permission]
(
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fdv_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_user_permission_idx1] ON [dbo].[aud_icts_user_permission] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_user_permission] ON [dbo].[aud_icts_user_permission] ([user_init], [fdv_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_icts_user_permission] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_icts_user_permission] TO [next_usr]
GO
