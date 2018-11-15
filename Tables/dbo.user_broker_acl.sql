CREATE TABLE [dbo].[user_broker_acl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[allow] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__0A750F57] DEFAULT ((0)),
[allow_administrator] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__0B693390] DEFAULT ((0)),
[allow_configure] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__0C5D57C9] DEFAULT ((0)),
[allow_exchange] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__0D517C02] DEFAULT ((0)),
[allow_management] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__0E45A03B] DEFAULT ((0)),
[allow_queue] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__0F39C474] DEFAULT ((0)),
[allow_read] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__102DE8AD] DEFAULT ((0)),
[allow_topic] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__11220CE6] DEFAULT ((0)),
[allow_write] [bit] NOT NULL CONSTRAINT [DF__user_brok__allow__1216311F] DEFAULT ((0)),
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
