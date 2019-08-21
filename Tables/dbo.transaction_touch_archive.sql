CREATE TABLE [dbo].[transaction_touch_archive]
(
[archive_date] [datetime] NOT NULL,
[operation] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[touch_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL,
[sequence] [numeric] (32, 0) NOT NULL,
[touch_key] [numeric] (32, 0) NOT NULL,
[tran_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transaction_touch_archive] ADD CONSTRAINT [transaction_touch_archive_pk] PRIMARY KEY CLUSTERED  ([touch_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [transaction_touch_archive_idx2] ON [dbo].[transaction_touch_archive] ([sequence], [touch_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [transaction_touch_archive_idx1] ON [dbo].[transaction_touch_archive] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transaction_touch_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[transaction_touch_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[transaction_touch_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[transaction_touch_archive] TO [next_usr]
GO
