CREATE TABLE [dbo].[tblGroupsConfig]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ConfigType] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[GroupName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Orden] [int] NULL,
[Row1] [int] NULL,
[Row2] [int] NULL,
[Col1] [int] NULL,
[Col2] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblGroupsConfig] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblGroupsConfig] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblGroupsConfig] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblGroupsConfig] TO [next_usr]
GO
