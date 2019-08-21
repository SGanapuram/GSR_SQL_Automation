CREATE TABLE [dbo].[aud_feed_definition_xsd_xml]
(
[oid] [int] NOT NULL,
[doc_text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_definition_xsd_xml] ON [dbo].[aud_feed_definition_xsd_xml] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_definition_xsd_xml_idx1] ON [dbo].[aud_feed_definition_xsd_xml] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_feed_definition_xsd_xml] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_feed_definition_xsd_xml] TO [next_usr]
GO
