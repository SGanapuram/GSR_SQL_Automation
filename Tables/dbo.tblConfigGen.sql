CREATE TABLE [dbo].[tblConfigGen]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ConfigType] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Commkt] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Comm] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Mkt] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Source] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SourceValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TradingPrd] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TradingPrdValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPYear] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPMonth] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPWeek] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPDay] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPCycle] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Price] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PPrec] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PPrecValue] [smallint] NULL,
[QuotedStart] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QuotedStartValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QsYear] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QsMonth] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QSDay] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QuotedEnd] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QEYear] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QEMonth] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QEDay] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Max] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MaxValue] [smallint] NULL,
[PriceInd] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PriceIndValue] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[High] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Low] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Avg] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Volume] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Open] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PutCall] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[OptionStrike] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StrikeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Volatility] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StrikePrec] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StrikePrecValue] [smallint] NULL,
[Expandavg] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MktDist] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblConfigGen] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblConfigGen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblConfigGen] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblConfigGen] TO [next_usr]
GO
