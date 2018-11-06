CREATE TABLE [dbo].[tblHitRecords]
(
[ConfigNAme] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DateDownload] [datetime] NULL,
[LinesRead] [int] NULL,
[RecordsHit] [int] NULL,
[AliasMatched] [int] NULL,
[AvgCalculated] [int] NULL,
[path] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EndTime] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblHitRecords] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblHitRecords] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblHitRecords] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblHitRecords] TO [next_usr]
GO
