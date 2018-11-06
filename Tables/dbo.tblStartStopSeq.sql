CREATE TABLE [dbo].[tblStartStopSeq]
(
[ConfigName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StartKeyword] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StartType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StartRowCol] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StartPosition] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StartString] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StopKeyWord] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StopType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StopRowCol] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StopPosition] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[StopString] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SeqNumber] [smallint] NULL,
[ConfigType] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblStartStopSeq] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblStartStopSeq] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblStartStopSeq] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblStartStopSeq] TO [next_usr]
GO
