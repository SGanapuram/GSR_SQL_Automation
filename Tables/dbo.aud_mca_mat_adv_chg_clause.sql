CREATE TABLE [dbo].[aud_mca_mat_adv_chg_clause]
(
[mca_num] [int] NOT NULL,
[macc_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_mat_adv_chg_clause] ON [dbo].[aud_mca_mat_adv_chg_clause] ([mca_num], [macc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_mat_adv_chg_clau_idx1] ON [dbo].[aud_mca_mat_adv_chg_clause] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_mca_mat_adv_chg_clause] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_mca_mat_adv_chg_clause] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_mca_mat_adv_chg_clause] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_mca_mat_adv_chg_clause] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mca_mat_adv_chg_clause] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_mca_mat_adv_chg_clause', NULL, NULL
GO
