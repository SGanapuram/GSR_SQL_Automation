CREATE TABLE [dbo].[tblAvgTemp]
(
[CommMarket] [int] NULL,
[TradingPrd] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PriceDate] [datetime] NULL,
[PriceSource] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Pricetype] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Update] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[High] [float] NULL,
[Low] [float] NULL,
[Avg] [float] NULL,
[CreationType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[HighOld] [float] NULL,
[LowOld] [float] NULL,
[OptionorPrice] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblAvgTemp] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblAvgTemp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblAvgTemp] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblAvgTemp] TO [next_usr]
GO
