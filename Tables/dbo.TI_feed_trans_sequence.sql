CREATE TABLE [dbo].[TI_feed_trans_sequence]
(
[oid] [int] NOT NULL,
[last_num] [int] NULL CONSTRAINT [DF__TI_feed_t__last___75785BC3] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_trans_sequence] ADD CONSTRAINT [TI_feed_trans_sequence_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TI_feed_trans_sequence] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_feed_trans_sequence] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_feed_trans_sequence] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_feed_trans_sequence] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'TI_feed_trans_sequence', NULL, NULL
GO
