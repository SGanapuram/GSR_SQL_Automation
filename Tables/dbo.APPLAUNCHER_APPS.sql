CREATE TABLE [dbo].[APPLAUNCHER_APPS]
(
[product] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[app_uid] [uniqueidentifier] NOT NULL,
[app_title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tile_size] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF_APPLAUNCHER_APPS_tile_size] DEFAULT (N'W'),
[tile_icon] [int] NULL,
[link_type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[link_path] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[link_invoke] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[autorun_order] [int] NULL,
[search_enabled] [bit] NOT NULL CONSTRAINT [DF_APPLAUNCHER_APPS_search_enabled] DEFAULT ((0)),
[search_default] [bit] NOT NULL CONSTRAINT [DF_APPLAUNCHER_APPS_search_default] DEFAULT ((0)),
[roles] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[enabled] [bit] NOT NULL CONSTRAINT [DF_APPLAUNCHER_APPS_enabled] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APPLAUNCHER_APPS] ADD CONSTRAINT [PK_APPLAUNCHER_APPS] PRIMARY KEY CLUSTERED  ([product], [app_uid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[APPLAUNCHER_APPS] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[APPLAUNCHER_APPS] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[APPLAUNCHER_APPS] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[APPLAUNCHER_APPS] TO [next_usr]
GO
