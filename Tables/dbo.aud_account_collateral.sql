CREATE TABLE [dbo].[aud_account_collateral]
(
[acct_num] [int] NOT NULL,
[collateral_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_collateral] ON [dbo].[aud_account_collateral] ([acct_num], [collateral_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_collateral_idx1] ON [dbo].[aud_account_collateral] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_collateral] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_collateral] TO [next_usr]
GO
