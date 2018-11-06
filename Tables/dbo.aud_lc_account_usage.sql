CREATE TABLE [dbo].[aud_lc_account_usage]
(
[lc_num] [int] NOT NULL,
[lc_acct_usage_num] [smallint] NOT NULL,
[lc_acct_usage] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NOT NULL,
[lc_acct_ref] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_account_usage] ON [dbo].[aud_lc_account_usage] ([lc_num], [lc_acct_usage_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_account_usage_idx1] ON [dbo].[aud_lc_account_usage] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lc_account_usage] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lc_account_usage] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lc_account_usage] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lc_account_usage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_account_usage] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lc_account_usage', NULL, NULL
GO
