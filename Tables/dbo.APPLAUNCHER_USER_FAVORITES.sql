CREATE TABLE [dbo].[APPLAUNCHER_USER_FAVORITES]
(
[product] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_uid] [uniqueidentifier] NOT NULL,
[position] [int] NOT NULL,
[category_uid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APPLAUNCHER_USER_FAVORITES] ADD CONSTRAINT [PK_APPLAUNCHER_FAVORITES] PRIMARY KEY CLUSTERED  ([product], [user_init], [app_uid], [category_uid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[APPLAUNCHER_USER_FAVORITES] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[APPLAUNCHER_USER_FAVORITES] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[APPLAUNCHER_USER_FAVORITES] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[APPLAUNCHER_USER_FAVORITES] TO [next_usr]
GO
