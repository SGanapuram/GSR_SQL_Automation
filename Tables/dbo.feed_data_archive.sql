CREATE TABLE [dbo].[feed_data_archive]
(
[oid] [int] NOT NULL,
[request_xml_id] [int] NOT NULL,
[response_xml_id] [int] NOT NULL,
[number_of_rows] [int] NOT NULL CONSTRAINT [DF__feed_data__numbe__76B698BF] DEFAULT ((0)),
[feed_id] [int] NOT NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [DF__feed_data__archi__77AABCF8] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_data_archive] ADD CONSTRAINT [feed_data_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_data_archive_idx1] ON [dbo].[feed_data_archive] ([archived_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[feed_data_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_data_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_data_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_data_archive] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'feed_data_archive', NULL, NULL
GO
