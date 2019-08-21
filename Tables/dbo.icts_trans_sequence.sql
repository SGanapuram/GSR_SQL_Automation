CREATE TABLE [dbo].[icts_trans_sequence]
(
[oid] [int] NOT NULL,
[last_num] [int] NOT NULL CONSTRAINT [df_icts_trans_sequence_last_num] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icts_trans_sequence] ADD CONSTRAINT [icts_trans_sequence_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[icts_trans_sequence] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[icts_trans_sequence] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[icts_trans_sequence] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_trans_sequence] TO [next_usr]
GO
