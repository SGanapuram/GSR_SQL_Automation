CREATE TABLE [dbo].[EmptySeqFiles]
(
[file] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DateTime] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EmptySeqFiles] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[EmptySeqFiles] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[EmptySeqFiles] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[EmptySeqFiles] TO [next_usr]
GO
