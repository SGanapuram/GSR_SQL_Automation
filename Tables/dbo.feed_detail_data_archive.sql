CREATE TABLE [dbo].[feed_detail_data_archive]
(
[oid] [int] NOT NULL,
[feed_data_id] [int] NOT NULL,
[request_xml_id] [int] NOT NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [df_feed_detail_data_archive_archived_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_detail_data_archive] ADD CONSTRAINT [feed_detail_data_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[feed_detail_data_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_detail_data_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_detail_data_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_detail_data_archive] TO [next_usr]
GO
