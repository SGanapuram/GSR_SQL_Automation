CREATE TABLE [dbo].[aud_mca_account]
(
[mca_num] [int] NOT NULL,
[coll_party_num] [int] NULL,
[acct_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_account] ON [dbo].[aud_mca_account] ([mca_num], [coll_party_num], [acct_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_account_idx1] ON [dbo].[aud_mca_account] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_mca_account] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_mca_account] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_mca_account] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_mca_account] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mca_account] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_mca_account', NULL, NULL
GO
