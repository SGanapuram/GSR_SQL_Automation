CREATE TABLE [dbo].[aud_account_group]
(
[related_acct_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[acct_group_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[parent_acct_own_pcnt] [float] NULL,
[acct_group_relation] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_group] ON [dbo].[aud_account_group] ([related_acct_num], [acct_num], [acct_group_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_group_idx1] ON [dbo].[aud_account_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_group] TO [next_usr]
GO
