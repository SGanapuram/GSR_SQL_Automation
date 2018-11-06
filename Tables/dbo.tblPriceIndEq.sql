CREATE TABLE [dbo].[tblPriceIndEq]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Configtype] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PriceIndCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Equivalent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Orden] [smallint] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPriceIndEq] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblPriceIndEq] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblPriceIndEq] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblPriceIndEq] TO [next_usr]
GO
