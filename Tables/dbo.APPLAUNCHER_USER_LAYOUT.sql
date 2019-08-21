CREATE TABLE [dbo].[APPLAUNCHER_USER_LAYOUT]
(
[product] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[layout] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APPLAUNCHER_USER_LAYOUT] ADD CONSTRAINT [PK_APPLAUNCHER_USER_LAYOUT] PRIMARY KEY CLUSTERED  ([product], [user_init]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[APPLAUNCHER_USER_LAYOUT] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[APPLAUNCHER_USER_LAYOUT] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[APPLAUNCHER_USER_LAYOUT] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[APPLAUNCHER_USER_LAYOUT] TO [next_usr]
GO
