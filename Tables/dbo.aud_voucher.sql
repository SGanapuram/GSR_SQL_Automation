CREATE TABLE [dbo].[aud_voucher]
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
[resp_trans_id] [int] NOT NULL,
[ref_voucher_num] [int] NULL,
[custom_voucher_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_reversal_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voucher_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_line_num] [int] NOT NULL,
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
CREATE NONCLUSTERED INDEX [aud_voucher_idx1] ON [dbo].[aud_voucher] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voucher] ON [dbo].[aud_voucher] ([voucher_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voucher] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voucher] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voucher] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voucher] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voucher] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voucher', NULL, NULL
GO
