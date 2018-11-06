CREATE TABLE [dbo].[tblPriceSourceEq]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Configtype] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PriceSourceCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Equivalent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPriceSourceEq] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblPriceSourceEq] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblPriceSourceEq] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblPriceSourceEq] TO [next_usr]
GO
