CREATE TABLE [dbo].[aud_voucher_approval]
(
[voucher_approval_num] [int] NOT NULL,
[gl_acct_dr_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gl_acct_cr_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voucher_approval_limit] [float] NOT NULL,
[book_comp_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_approval_idx1] ON [dbo].[aud_voucher_approval] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_approval] ON [dbo].[aud_voucher_approval] ([voucher_approval_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_voucher_approval] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_approval] TO [next_usr]
GO
