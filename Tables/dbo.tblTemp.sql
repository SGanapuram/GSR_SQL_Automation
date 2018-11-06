CREATE TABLE [dbo].[tblTemp]
(
[LineNo] [smallint] NULL,
[CommktKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Comm] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Market] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Source] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TradingPrd] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPYear] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPMonth] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPDay] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TPWeek] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QSYear] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QSMonth] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QSDay] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QEYear] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QEMonth] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[QEDay] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Price] [float] NULL,
[PricePrec] [smallint] NULL,
[PriceInd] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[High] [real] NULL,
[Low] [float] NULL,
[Avg] [float] NULL,
[Volume] [float] NULL,
[Open] [float] NULL,
[OptStrike] [int] NULL,
[Volatility] [int] NULL,
[PutCall] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Divided] [float] NULL,
[Mapped] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblTemp] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblTemp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblTemp] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblTemp] TO [next_usr]
GO
