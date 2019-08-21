CREATE TABLE [dbo].[voucher_payment]
(
[voucher_num] [int] NOT NULL,
[voucher_pay_num] [smallint] NOT NULL,
[voucher_pay_amt] [float] NOT NULL,
[voucher_pay_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voucher_pay_ref] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_payment_applied_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[payment_approval_trans_id] [int] NULL,
[sent_on_date] [datetime] NULL,
[payment_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_voucher_payment_payment_status] DEFAULT ('Paid'),
[processed_date] [datetime] NOT NULL CONSTRAINT [df_voucher_payment_processed_date] DEFAULT (getdate()),
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
ALTER TABLE [dbo].[voucher_payment] ADD CONSTRAINT [voucher_payment_pk] PRIMARY KEY CLUSTERED  ([voucher_num], [voucher_pay_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [voucher_payment_idx1] ON [dbo].[voucher_payment] ([voucher_num]) INCLUDE ([processed_date], [voucher_pay_amt]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_payment] ADD CONSTRAINT [voucher_payment_fk1] FOREIGN KEY ([voucher_pay_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher_payment] ADD CONSTRAINT [voucher_payment_fk3] FOREIGN KEY ([effective_acct_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher_payment] ADD CONSTRAINT [voucher_payment_fk4] FOREIGN KEY ([confirmed_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher_payment] ADD CONSTRAINT [voucher_payment_fk5] FOREIGN KEY ([cmnt_num]) REFERENCES [dbo].[comment] ([cmnt_num])
GO
ALTER TABLE [dbo].[voucher_payment] ADD CONSTRAINT [voucher_payment_fk6] FOREIGN KEY ([payee_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[voucher_payment] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_payment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_payment] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_payment] TO [next_usr]
GO
