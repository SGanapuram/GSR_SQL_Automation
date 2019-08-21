CREATE TABLE [dbo].[TI_inbound_data_xml]
(
[oid] [int] NOT NULL,
[trans_date] [datetime] NOT NULL,
[request_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[response_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[row_count] [int] NOT NULL,
[feed_oid] [int] NOT NULL,
[ws_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_TI_inbound_data_xml_ws_status] DEFAULT ('PENDING'),
[dd_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_TI_inbound_data_xml_dd_status] DEFAULT ('PENDING'),
[dd_instance_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_inbound_data_xml] ADD CONSTRAINT [chk_TI_inbound_data_xml_dd_status] CHECK (([dd_status]='INCOMPLETED' OR [dd_status]='FAILED' OR [dd_status]='COMPLETED' OR [dd_status]='PROCESSING' OR [dd_status]='PENDING'))
GO
ALTER TABLE [dbo].[TI_inbound_data_xml] ADD CONSTRAINT [chk_TI_inbound_data_xml_ws_status] CHECK (([ws_status]='ERROR' OR [ws_status]='FAILED' OR [ws_status]='COMPLETED' OR [ws_status]='PROCESSING' OR [ws_status]='PENDING'))
GO
ALTER TABLE [dbo].[TI_inbound_data_xml] ADD CONSTRAINT [TI_inbound_data_xml_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_inbound_data_xml] ADD CONSTRAINT [TI_inbound_data_xml_fk1] FOREIGN KEY ([feed_oid]) REFERENCES [dbo].[TI_feed_definition] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_inbound_data_xml] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_inbound_data_xml] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_inbound_data_xml] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_inbound_data_xml] TO [next_usr]
GO
