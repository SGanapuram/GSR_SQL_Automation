CREATE TABLE [dbo].[aud_feed_definition]
(
[oid] [int] NOT NULL,
[feed_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[request_xsd_id] [int] NULL,
[response_xsd_id] [int] NULL,
[mapping_xml_id] [int] NULL,
[active_ind] [bit] NOT NULL CONSTRAINT [DF__aud_feed___activ__54376389] DEFAULT ((1)),
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[display_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[interface] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_definition] ON [dbo].[aud_feed_definition] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_feed_definition_idx1] ON [dbo].[aud_feed_definition] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_feed_definition] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_feed_definition] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_feed_definition] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_feed_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_feed_definition] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_feed_definition', NULL, NULL
GO
