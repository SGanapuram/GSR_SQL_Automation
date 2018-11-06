CREATE TABLE [dbo].[APPLAUNCHER_CATEGORIES]
(
[product] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[category_uid] [uniqueidentifier] NOT NULL,
[category_title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[category_parent] [uniqueidentifier] NULL,
[tile_color] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tile_icon] [int] NULL,
[type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[linkspanel_itemswidth] [int] NULL,
[linkspanel_rows] [int] NULL,
[position] [int] NULL,
[enabled] [bit] NOT NULL CONSTRAINT [DF_APPLAUNCHER_CATEGORIES_enabled] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APPLAUNCHER_CATEGORIES] ADD CONSTRAINT [PK_APPLAUNCHER_CATEGORIES] PRIMARY KEY CLUSTERED  ([product], [category_uid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[APPLAUNCHER_CATEGORIES] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[APPLAUNCHER_CATEGORIES] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[APPLAUNCHER_CATEGORIES] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[APPLAUNCHER_CATEGORIES] TO [next_usr]
GO
