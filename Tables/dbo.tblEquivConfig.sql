CREATE TABLE [dbo].[tblEquivConfig]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Configtype] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Option] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ValueParam] [smallint] NULL,
[ValueParam2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblEquivConfig] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblEquivConfig] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblEquivConfig] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblEquivConfig] TO [next_usr]
GO
