CREATE TABLE [dbo].[tblTest]
(
[Commkt] [int] NULL,
[Trading] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Source] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Date] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblTest] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblTest] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblTest] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblTest] TO [next_usr]
GO
