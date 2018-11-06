CREATE TABLE [dbo].[TI_feed_transaction]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[feed_row_oid] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[key1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[resp_trans_id] [int] NOT NULL,
[dd_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__TI_feed_t__dd_st__7854C86E] DEFAULT ('PENDING'),
[dd_instance_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_transaction] ADD CONSTRAINT [CK__TI_feed_t__dd_st__7948ECA7] CHECK (([dd_status]='INCOMPLETED' OR [dd_status]='FAILED' OR [dd_status]='COMPLETED' OR [dd_status]='PROCESSING' OR [dd_status]='PENDING'))
GO
ALTER TABLE [dbo].[TI_feed_transaction] ADD CONSTRAINT [TI_feed_transaction_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_transaction] ADD CONSTRAINT [TI_feed_transaction_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
ALTER TABLE [dbo].[TI_feed_transaction] ADD CONSTRAINT [TI_feed_transaction_fk2] FOREIGN KEY ([entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_feed_transaction] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_feed_transaction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_feed_transaction] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_feed_transaction] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_feed_transaction', NULL, NULL
GO
