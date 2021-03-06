CREATE TABLE [dbo].[feed_xsd_xml_text_archive]
(
[oid] [int] NOT NULL,
[doc_text] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [df_feed_xsd_xml_text_archive_archived_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_xsd_xml_text_archive] ADD CONSTRAINT [feed_xsd_xml_text_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_xsd_xml_text_archive_idx1] ON [dbo].[feed_xsd_xml_text_archive] ([archived_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[feed_xsd_xml_text_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_xsd_xml_text_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_xsd_xml_text_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_xsd_xml_text_archive] TO [next_usr]
GO
