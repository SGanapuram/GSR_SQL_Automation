CREATE TABLE [dbo].[TI_inbound_data_xml]
(
[oid] [int] NOT NULL,
[trans_date] [datetime] NOT NULL,
[request_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[response_xml] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[row_count] [int] NOT NULL,
[feed_oid] [int] NOT NULL,
[ws_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__TI_inboun__ws_st__7FF5EA36] DEFAULT ('PENDING'),
[dd_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__TI_inboun__dd_st__01DE32A8] DEFAULT ('PENDING'),
[dd_instance_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_inbound_data_xml] ADD CONSTRAINT [CK__TI_inboun__dd_st__02D256E1] CHECK (([dd_status]='INCOMPLETED' OR [dd_status]='FAILED' OR [dd_status]='COMPLETED' OR [dd_status]='PROCESSING' OR [dd_status]='PENDING'))
GO
ALTER TABLE [dbo].[TI_inbound_data_xml] ADD CONSTRAINT [CK__TI_inboun__ws_st__00EA0E6F] CHECK (([ws_status]='ERROR' OR [ws_status]='FAILED' OR [ws_status]='COMPLETED' OR [ws_status]='PROCESSING' OR [ws_status]='PENDING'))
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
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_inbound_data_xml', NULL, NULL
GO
