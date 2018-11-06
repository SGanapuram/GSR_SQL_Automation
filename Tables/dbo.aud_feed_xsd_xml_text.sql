CREATE TABLE [dbo].[aud_feed_xsd_xml_text]
(
[oid] [int] NOT NULL,
[doc_text] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_xsd_xml_text] ON [dbo].[aud_feed_xsd_xml_text] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_xsd_xml_text_idx1] ON [dbo].[aud_feed_xsd_xml_text] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_feed_xsd_xml_text] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_feed_xsd_xml_text] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_feed_xsd_xml_text] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_feed_xsd_xml_text] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_feed_xsd_xml_text] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_feed_xsd_xml_text', NULL, NULL
GO
