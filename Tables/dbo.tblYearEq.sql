CREATE TABLE [dbo].[tblYearEq]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Configtype] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Year] [int] NULL,
[Equivalent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblYearEq] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblYearEq] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblYearEq] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblYearEq] TO [next_usr]
GO
