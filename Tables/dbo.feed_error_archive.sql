CREATE TABLE [dbo].[feed_error_archive]
(
[oid] [int] NOT NULL,
[feed_data_id] [int] NOT NULL,
[feed_detail_data_id] [int] NULL,
[description] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [df_feed_error_archive_archived_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_error_archive] ADD CONSTRAINT [feed_error_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_error_archive_idx1] ON [dbo].[feed_error_archive] ([archived_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[feed_error_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_error_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_error_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_error_archive] TO [next_usr]
GO
