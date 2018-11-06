CREATE TABLE [dbo].[SpotPrices]
(
[Commkt] [int] NULL,
[TradingPrd] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Date] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Low] [float] NULL,
[High] [float] NULL,
[Avg] [float] NULL,
[Open] [float] NULL,
[Volume] [float] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SpotPrices] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[SpotPrices] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[SpotPrices] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[SpotPrices] TO [next_usr]
GO
