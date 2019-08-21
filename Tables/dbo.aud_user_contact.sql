CREATE TABLE [dbo].[aud_user_contact]
(
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NOT NULL,
[acct_cont_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_contact_idx1] ON [dbo].[aud_user_contact] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_contact] ON [dbo].[aud_user_contact] ([user_init], [acct_num], [acct_cont_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_user_contact] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_user_contact] TO [next_usr]
GO
