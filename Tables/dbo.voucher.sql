CREATE TABLE [dbo].[voucher]
(
[voucher_num] [int] NOT NULL,
[voucher_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_cat_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_pay_recv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_instr_num] [smallint] NULL,
[voucher_tot_amt] [float] NULL,
[voucher_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_pay_days] [smallint] NULL,
[voch_tot_paid_amt] [float] NULL,
[voucher_creation_date] [datetime] NULL,
[voucher_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_auth_reqd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_auth_date] [datetime] NULL,
[voucher_auth_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_eff_date] [datetime] NULL,
[voucher_print_date] [datetime] NULL,
[voucher_send_to_cust_date] [datetime] NULL,
[voucher_book_date] [datetime] NULL,
[voucher_mod_date] [datetime] NULL,
[voucher_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_writeoff_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_writeoff_date] [datetime] NULL,
[voucher_cust_inv_amt] [float] NULL,
[voucher_cust_inv_date] [datetime] NULL,
[voucher_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[voucher_book_comp_num] [int] NULL,
[voucher_book_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_book_exch_rate] [float] NULL,
[voucher_xrate_conv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_loi_num] [int] NULL,
[voucher_arap_acct_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_send_to_arap_date] [datetime] NULL,
[voucher_cust_ref_num] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_book_prd_date] [datetime] NULL,
[voucher_paid_date] [datetime] NULL,
[voucher_due_date] [datetime] NULL,
[voucher_acct_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_book_comp_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cash_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[ref_voucher_num] [int] NULL,
[custom_voucher_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_reversal_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_voucher_voucher_reversal_ind] DEFAULT ('N'),
[voucher_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_voucher_voucher_hold_ind] DEFAULT ('N'),
[max_line_num] [int] NOT NULL CONSTRAINT [df_voucher_max_line_num] DEFAULT ((0)),
[book_comp_acct_bank_id] [int] NULL,
[cp_acct_bank_id] [int] NULL,
[voucher_inv_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_inv_exch_rate] [numeric] (20, 8) NULL,
[invoice_exch_rate_comment] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cust_inv_recv_date] [datetime] NULL,
[cust_inv_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[special_bank_instr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[revised_book_comp_bank_id] [int] NULL,
[voucher_expected_pay_date] [datetime] NULL,
[external_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cpty_inv_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_approval_date] [datetime] NULL,
[voucher_approval_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_invoice_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [chk_voucher_voucher_hold_ind] CHECK (([voucher_hold_ind]='M' OR [voucher_hold_ind]='Y' OR [voucher_hold_ind]='N'))
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [chk_voucher_voucher_reversal_ind] CHECK (([voucher_reversal_ind]='N' OR [voucher_reversal_ind]='Y'))
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [chk_voucher_voucher_status] CHECK (([voucher_status]='T' OR [voucher_status]='P' OR [voucher_status]='F' OR [voucher_status]=NULL))
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_pk] PRIMARY KEY CLUSTERED  ([voucher_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [voucher_idx1] ON [dbo].[voucher] ([ref_voucher_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk10] FOREIGN KEY ([voucher_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk11] FOREIGN KEY ([voucher_writeoff_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk12] FOREIGN KEY ([pay_method_code]) REFERENCES [dbo].[payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk13] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk15] FOREIGN KEY ([book_comp_acct_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk16] FOREIGN KEY ([cp_acct_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk17] FOREIGN KEY ([voucher_inv_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk18] FOREIGN KEY ([revised_book_comp_bank_id]) REFERENCES [dbo].[account_bank_info] ([acct_bank_id])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk19] FOREIGN KEY ([cpty_inv_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk2] FOREIGN KEY ([voucher_book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk20] FOREIGN KEY ([voucher_approval_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk3] FOREIGN KEY ([acct_num], [acct_instr_num]) REFERENCES [dbo].[account_instruction] ([acct_num], [acct_instr_num])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk5] FOREIGN KEY ([voucher_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk6] FOREIGN KEY ([voucher_book_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk7] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk8] FOREIGN KEY ([voucher_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[voucher] ADD CONSTRAINT [voucher_fk9] FOREIGN KEY ([voucher_auth_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[voucher] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher] TO [next_usr]
GO
