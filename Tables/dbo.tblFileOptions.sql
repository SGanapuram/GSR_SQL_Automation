CREATE TABLE [dbo].[tblFileOptions]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FileType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DelimitedType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DelimitedChar] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RowsNo] [smallint] NULL,
[CharEndRow] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PosEndRow] [smallint] NULL,
[CharEndPrice] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RowEndPrice] [smallint] NULL,
[ColEndPrice] [smallint] NULL,
[AliasSourceCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFileOptions] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblFileOptions] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblFileOptions] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblFileOptions] TO [next_usr]
GO
