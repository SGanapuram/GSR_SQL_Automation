CREATE TABLE [dbo].[feed_transaction_archive]
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
[operation] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [DF__feed_tran__archi__162F4418] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_transaction_archive] ADD CONSTRAINT [feed_transaction_archive_pk] PRIMARY KEY CLUSTERED  ([oid], [archived_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feed_transaction_archive_idx1] ON [dbo].[feed_transaction_archive] ([archived_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[feed_transaction_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_transaction_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_transaction_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_transaction_archive] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'feed_transaction_archive', NULL, NULL
GO
