CREATE TABLE [dbo].[icts_trans_sequence]
(
[oid] [int] NOT NULL,
[last_num] [int] NOT NULL CONSTRAINT [DF__icts_tran__last___2724C5F0] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[icts_trans_sequence] ADD CONSTRAINT [UQ__icts_tra__C2FFCF12253C7D7E] UNIQUE NONCLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[icts_trans_sequence] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[icts_trans_sequence] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'icts_trans_sequence', NULL, NULL
GO
