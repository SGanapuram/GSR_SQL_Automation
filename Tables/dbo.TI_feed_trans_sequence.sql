CREATE TABLE [dbo].[TI_feed_trans_sequence]
(
[oid] [int] NOT NULL,
[last_num] [int] NULL CONSTRAINT [df_TI_feed_trans_sequence_last_num] DEFAULT ((0))
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
