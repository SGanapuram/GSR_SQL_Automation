CREATE TABLE [dbo].[aud_contract_skeleton]
(
[contr_num] [int] NOT NULL,
[contr_rev_num] [int] NOT NULL,
[contr_skel_num] [int] NOT NULL,
[contr_skel_data] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_skeleton] ON [dbo].[aud_contract_skeleton] ([contr_num], [contr_rev_num], [contr_skel_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_skeleton_idx1] ON [dbo].[aud_contract_skeleton] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_contract_skeleton] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_contract_skeleton] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_contract_skeleton] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_contract_skeleton] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract_skeleton] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_contract_skeleton', NULL, NULL
GO
