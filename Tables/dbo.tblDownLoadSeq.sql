CREATE TABLE [dbo].[tblDownLoadSeq]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Path] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PatorFile] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FileName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Orden] [smallint] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblDownLoadSeq] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblDownLoadSeq] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblDownLoadSeq] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblDownLoadSeq] TO [next_usr]
GO
