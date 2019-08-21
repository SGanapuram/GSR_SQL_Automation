CREATE TABLE [dbo].[aud_feed_detail_data]
(
[oid] [int] NOT NULL,
[feed_data_id] [int] NOT NULL,
[request_xml_id] [int] NOT NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_detail_data] ON [dbo].[aud_feed_detail_data] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_detail_data_idx1] ON [dbo].[aud_feed_detail_data] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_feed_detail_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_feed_detail_data] TO [next_usr]
GO
