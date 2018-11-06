CREATE TABLE [dbo].[aud_icts_user]
(
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_last_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_first_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[desk_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_logon_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[us_citizen_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_job_title] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_employee_num] [int] NULL,
[email_address] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_user_idx1] ON [dbo].[aud_icts_user] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_user] ON [dbo].[aud_icts_user] ([user_init], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_icts_user] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_icts_user] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_icts_user] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_icts_user] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_icts_user] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_icts_user', NULL, NULL
GO
