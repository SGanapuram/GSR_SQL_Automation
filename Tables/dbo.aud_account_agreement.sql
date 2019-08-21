CREATE TABLE [dbo].[aud_account_agreement]
(
[agreement_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[trade_group_num] [int] NOT NULL,
[product_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[agreement_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ext_agreement_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confirm_by] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[target_book_comp_num] [int] NULL,
[forward_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voucher_netting_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_agreement] ON [dbo].[aud_account_agreement] ([agreement_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_account_agreement_idx1] ON [dbo].[aud_account_agreement] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_account_agreement] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_account_agreement] TO [next_usr]
GO
