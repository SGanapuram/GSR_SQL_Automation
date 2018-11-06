CREATE TABLE [dbo].[tblErrors]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Line] [int] NULL,
[Group] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Error] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ErrString] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[WholeLine] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblErrors] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblErrors] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblErrors] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblErrors] TO [next_usr]
GO
