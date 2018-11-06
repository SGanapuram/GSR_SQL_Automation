CREATE TABLE [dbo].[tblDownloadTracker]
(
[ConfigNAme] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Date] [datetime] NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[Status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LastLine] [smallint] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblDownloadTracker] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tblDownloadTracker] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tblDownloadTracker] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tblDownloadTracker] TO [next_usr]
GO
