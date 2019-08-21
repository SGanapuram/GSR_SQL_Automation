CREATE TABLE [dbo].[feed_trans_sequence]
(
[oid] [int] NOT NULL,
[last_num] [int] NOT NULL CONSTRAINT [df_feed_trans_sequence_last_num] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feed_trans_sequence] ADD CONSTRAINT [feed_trans_sequence_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[feed_trans_sequence] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[feed_trans_sequence] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[feed_trans_sequence] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[feed_trans_sequence] TO [next_usr]
GO
