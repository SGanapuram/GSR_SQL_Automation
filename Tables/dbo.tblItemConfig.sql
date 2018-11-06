CREATE TABLE [dbo].[tblItemConfig]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Configtype] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Item] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Setto] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Orden] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LengthType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Length] [int] NULL,
[String] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TotalOrder] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblItemConfig] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblItemConfig] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblItemConfig] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblItemConfig] TO [next_usr]
GO
