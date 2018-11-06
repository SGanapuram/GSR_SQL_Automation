CREATE TABLE [dbo].[tblRunfiles]
(
[FilePath] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fileName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Orden] [smallint] NULL,
[StartEnd] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblRunfiles] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblRunfiles] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblRunfiles] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblRunfiles] TO [next_usr]
GO
