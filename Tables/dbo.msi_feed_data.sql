CREATE TABLE [dbo].[msi_feed_data]
(
[oid] [int] NOT NULL,
[feed_data_id] [int] NOT NULL,
[msg_control_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sendg_appl] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[receivg_appl] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[msg_date] [datetime] NULL,
[msg_time] [datetime] NULL,
[msg_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_msg_control_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[msg_category] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[req_res_xml_id] [int] NULL,
[response_recv] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_feed_data] ADD CONSTRAINT [msi_feed_data_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[msi_feed_data] ADD CONSTRAINT [msi_feed_data_fk1] FOREIGN KEY ([feed_data_id]) REFERENCES [dbo].[feed_data] ([oid])
GO
ALTER TABLE [dbo].[msi_feed_data] ADD CONSTRAINT [msi_feed_data_fk2] FOREIGN KEY ([req_res_xml_id]) REFERENCES [dbo].[feed_xsd_xml_text] ([oid])
GO
GRANT DELETE ON  [dbo].[msi_feed_data] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[msi_feed_data] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[msi_feed_data] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[msi_feed_data] TO [next_usr]
GO
