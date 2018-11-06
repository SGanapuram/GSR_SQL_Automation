CREATE TABLE [dbo].[aud_voucher_pay_approval]
(
[voucher_pay_approval_num] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[payment_approval_limit] [float] NOT NULL,
[book_comp_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vouch_pay_approval_idx1] ON [dbo].[aud_voucher_pay_approval] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_pay_approval] ON [dbo].[aud_voucher_pay_approval] ([voucher_pay_approval_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher_pay_approval] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher_pay_approval] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher_pay_approval] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher_pay_approval] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_pay_approval] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher_pay_approval', NULL, NULL
GO
