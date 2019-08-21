CREATE TABLE [dbo].[aud_feed_data]
(
[oid] [int] NOT NULL,
[request_xml_id] [int] NOT NULL,
[response_xml_id] [int] NOT NULL,
[number_of_rows] [int] NOT NULL,
[feed_id] [int] NOT NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_data] ON [dbo].[aud_feed_data] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_data_idx1] ON [dbo].[aud_feed_data] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_feed_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_feed_data] TO [next_usr]
GO
