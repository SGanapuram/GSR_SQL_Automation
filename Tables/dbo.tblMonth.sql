CREATE TABLE [dbo].[tblMonth]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ConfigType] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Owner] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Equivalent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[OrderMonth] [smallint] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMonth] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblMonth] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblMonth] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblMonth] TO [next_usr]
GO
