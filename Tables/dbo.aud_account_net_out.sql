CREATE TABLE [dbo].[aud_account_net_out]
(
[acct_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[net_out_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_net_out] ON [dbo].[aud_account_net_out] ([acct_num], [cmdty_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_net_out_idx1] ON [dbo].[aud_account_net_out] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_account_net_out] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_account_net_out] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_account_net_out] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_account_net_out] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_net_out] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_account_net_out', NULL, NULL
GO
