CREATE TABLE [dbo].[aud_user_group]
(
[user_group_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_group_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_group_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[netinfo_mail_alias] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_group_idx1] ON [dbo].[aud_user_group] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_group] ON [dbo].[aud_user_group] ([user_group_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_user_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_user_group] TO [next_usr]
GO
