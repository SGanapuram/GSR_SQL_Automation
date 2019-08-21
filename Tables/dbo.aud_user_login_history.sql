CREATE TABLE [dbo].[aud_user_login_history]
(
[oid] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_host_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_pool_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_port_number] [int] NOT NULL,
[originating_ip_address] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[session_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[termination_status_type] [int] NULL,
[start_date] [datetime] NOT NULL,
[end_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_login_history] ON [dbo].[aud_user_login_history] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_user_login_history_idx1] ON [dbo].[aud_user_login_history] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_user_login_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_user_login_history] TO [next_usr]
GO
