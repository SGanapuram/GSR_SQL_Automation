CREATE TABLE [dbo].[aud_acct_bookcomp]
(
[acct_bookcomp_key] [int] NOT NULL,
[acct_bookcomp_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NOT NULL,
[bookcomp_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp] ON [dbo].[aud_acct_bookcomp] ([acct_bookcomp_key], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bookcomp_idx1] ON [dbo].[aud_acct_bookcomp] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_acct_bookcomp] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_acct_bookcomp] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_acct_bookcomp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_bookcomp] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_acct_bookcomp', NULL, NULL
GO
