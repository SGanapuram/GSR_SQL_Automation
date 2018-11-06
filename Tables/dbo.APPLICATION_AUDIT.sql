CREATE TABLE [dbo].[APPLICATION_AUDIT]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[application] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date] [datetime] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[operation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gui_element] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APPLICATION_AUDIT] ADD CONSTRAINT [PK_APPLICATION_USER_AUDIT] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[APPLICATION_AUDIT] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[APPLICATION_AUDIT] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[APPLICATION_AUDIT] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[APPLICATION_AUDIT] TO [next_usr]
GO
