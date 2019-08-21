CREATE TABLE [dbo].[aud_account_affiliated]
(
[cntparty_acct_num] [int] NOT NULL,
[booking_comp_num] [int] NOT NULL,
[affiliate_type] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_affiliated_idx] ON [dbo].[aud_account_affiliated] ([cntparty_acct_num], [booking_comp_num], [affiliate_type], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_affiliated] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_affiliated] TO [next_usr]
GO
