CREATE TABLE [dbo].[filedownloader]
(
[fileDownloaderid] [int] NOT NULL IDENTITY(1, 1),
[fileName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ts] [bigint] NOT NULL,
[status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dt] [datetime] NOT NULL,
[machine] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[provider] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fileSize] [int] NOT NULL,
[message] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[filedownloader] ADD CONSTRAINT [filedownloader_pk] PRIMARY KEY CLUSTERED  ([fileDownloaderid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[filedownloader] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[filedownloader] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[filedownloader] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[filedownloader] TO [next_usr]
GO
