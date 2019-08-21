CREATE TABLE [dbo].[TI_feed_error]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[feed_row_oid] [int] NULL,
[description] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_error] ADD CONSTRAINT [TI_feed_error_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_error] ADD CONSTRAINT [TI_feed_error_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_feed_error] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_feed_error] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_feed_error] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_feed_error] TO [next_usr]
GO
