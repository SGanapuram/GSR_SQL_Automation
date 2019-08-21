CREATE TABLE [dbo].[user_broker_acl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[allow] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow] DEFAULT ((0)),
[allow_administrator] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_administrator] DEFAULT ((0)),
[allow_configure] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_configure] DEFAULT ((0)),
[allow_exchange] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_exchange] DEFAULT ((0)),
[allow_management] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_management] DEFAULT ((0)),
[allow_queue] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_queue] DEFAULT ((0)),
[allow_read] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_read] DEFAULT ((0)),
[allow_topic] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_topic] DEFAULT ((0)),
[allow_write] [bit] NOT NULL CONSTRAINT [df_user_broker_acl_allow_write] DEFAULT ((0)),
[user_logon_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vHost] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_broker_acl] ADD CONSTRAINT [user_broker_acl_PK] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[user_broker_acl] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[user_broker_acl] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[user_broker_acl] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[user_broker_acl] TO [next_usr]
GO
