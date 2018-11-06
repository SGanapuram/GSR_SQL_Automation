CREATE TABLE [dbo].[aud_voucher_payment]
(
[voucher_num] [int] NOT NULL,
[voucher_pay_num] [smallint] NOT NULL,
[voucher_pay_amt] [float] NOT NULL,
[voucher_pay_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voucher_pay_ref] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_payment_applied_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[payment_approval_trans_id] [int] NULL,
[sent_on_date] [datetime] NULL,
[payment_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[processed_date] [datetime] NOT NULL,
[paid_date] [datetime] NULL,
[effective_acct_bank_id] [int] NULL,
[confirmed_by_bank] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[confirmed_by_cp] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[value_date] [datetime] NULL,
[confirmed_amt] [numeric] (20, 8) NULL,
[confirmed_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[payee_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_payment_idx1] ON [dbo].[aud_voucher_payment] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher_payment] ON [dbo].[aud_voucher_payment] ([voucher_num], [voucher_pay_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher_payment] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher_payment] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher_payment] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher_payment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher_payment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher_payment', NULL, NULL
GO
