CREATE TABLE [dbo].[tblAlias]
(
[Alias] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Commkt] [int] NULL,
[TradingPrd] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Source] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Ind] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Factor] [float] NULL,
[Rec] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblAlias] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblAlias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblAlias] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblAlias] TO [next_usr]
GO
