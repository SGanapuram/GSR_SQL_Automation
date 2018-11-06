CREATE TABLE [dbo].[tblPutCall]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PutEquivalent] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CallEquivalent] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPutCall] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblPutCall] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblPutCall] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblPutCall] TO [next_usr]
GO
