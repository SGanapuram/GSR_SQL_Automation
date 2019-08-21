CREATE TABLE [dbo].[APPLAUNCHER_USER_DASHBOARDS]
(
[product] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[filename] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[position] [int] NULL,
[enabled] [bit] NOT NULL CONSTRAINT [df_APPLAUNCHER_USER_DASHBOARDS_enabled] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APPLAUNCHER_USER_DASHBOARDS] ADD CONSTRAINT [PK_APPLAUNCHER_USER_DASHBOARDS] PRIMARY KEY CLUSTERED  ([product], [user_init], [filename]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[APPLAUNCHER_USER_DASHBOARDS] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[APPLAUNCHER_USER_DASHBOARDS] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[APPLAUNCHER_USER_DASHBOARDS] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[APPLAUNCHER_USER_DASHBOARDS] TO [next_usr]
GO
