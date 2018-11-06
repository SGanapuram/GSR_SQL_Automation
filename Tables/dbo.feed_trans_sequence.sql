CREATE TABLE [dbo].[feed_trans_sequence]
(
[oid] [int] NOT NULL,
[last_num] [int] NOT NULL CONSTRAINT [DF__feed_tran__last___0F824689] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_trans_sequence] ADD CONSTRAINT [feed_trans_sequence_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[feed_trans_sequence] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_trans_sequence] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'feed_trans_sequence', NULL, NULL
GO
