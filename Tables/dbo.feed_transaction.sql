CREATE TABLE [dbo].[feed_transaction]
(
[oid] [int] NOT NULL,
[feed_data_id] [int] NOT NULL,
[feed_detail_data_id] [int] NOT NULL,
[entity_id] [int] NOT NULL,
[key1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operation] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__feed_tran__opera__125EB334] DEFAULT ('I')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_transaction] ADD CONSTRAINT [CK__feed_tran__opera__1352D76D] CHECK (([operation]='D' OR [operation]='U' OR [operation]='I'))
GO
ALTER TABLE [dbo].[feed_transaction] ADD CONSTRAINT [feed_transaction_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_transaction] ADD CONSTRAINT [feed_transaction_fk1] FOREIGN KEY ([feed_data_id]) REFERENCES [dbo].[feed_data] ([oid])
GO
ALTER TABLE [dbo].[feed_transaction] ADD CONSTRAINT [feed_transaction_fk2] FOREIGN KEY ([feed_detail_data_id]) REFERENCES [dbo].[feed_detail_data] ([oid])
GO
ALTER TABLE [dbo].[feed_transaction] ADD CONSTRAINT [feed_transaction_fk3] FOREIGN KEY ([entity_id]) REFERENCES [dbo].[icts_entity_name] ([oid])
GO
GRANT DELETE ON  [dbo].[feed_transaction] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_transaction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_transaction] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_transaction] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'feed_transaction', NULL, NULL
GO
