CREATE TABLE [dbo].[tblWeekEq]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Week] [int] NULL,
[Equivalent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblWeekEq] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblWeekEq] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblWeekEq] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblWeekEq] TO [next_usr]
GO
