CREATE TABLE [dbo].[aud_cost]
(
[cost_num] [int] NOT NULL,
[cost_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_status] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_prim_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_est_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bus_cost_type_num] [smallint] NULL,
[bus_cost_state_num] [smallint] NULL,
[bus_cost_fate_num] [smallint] NULL,
[bus_cost_fate_mod_date] [datetime] NULL,
[bus_cost_fate_mod_init] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key1] [int] NULL,
[cost_owner_key2] [int] NULL,
[cost_owner_key3] [int] NULL,
[cost_owner_key4] [int] NULL,
[cost_owner_key5] [int] NULL,
[cost_owner_key6] [int] NULL,
[cost_owner_key7] [int] NULL,
[cost_owner_key8] [int] NULL,
[parent_cost_num] [int] NULL,
[port_num] [int] NULL,
[pos_group_num] [int] NULL,
[acct_num] [int] NULL,
[cost_qty] [float] NULL,
[cost_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_qty_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_unit_price] [float] NULL,
[cost_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_amt] [float] NULL,
[cost_amt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_vouchered_amt] [float] NULL,
[cost_drawn_bal_amt] [float] NULL,
[pay_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pay_days] [smallint] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_comp_num] [int] NULL,
[cost_book_comp_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_prd_date] [datetime] NULL,
[cost_book_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_book_exch_rate] [float] NULL,
[cost_xrate_conv_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_eff_date] [datetime] NULL,
[cost_due_date] [datetime] NULL,
[cost_due_date_mod_date] [datetime] NULL,
[cost_due_date_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_approval_date] [datetime] NULL,
[cost_approval_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_acct_cr_code] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_acct_dr_code] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_acct_mod_date] [datetime] NULL,
[cost_gl_acct_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_book_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_book_date] [datetime] NULL,
[cost_gl_book_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_gl_offset_acct_code] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[cost_accrual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_price_mod_date] [datetime] NULL,
[cost_price_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_partial_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[first_accrued_date] [datetime] NULL,
[cost_period_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_pl_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_paid_date] [datetime] NULL,
[cost_credit_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center_code_debt] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center_code_credit] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_send_id] [smallint] NULL,
[vc_acct_num] [int] NULL,
[cash_date] [datetime] NULL,
[po_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[eff_date_override_trans_id] [int] NULL,
[finance_bank_num] [int] NULL,
[tax_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_rate_oid] [int] NULL,
[template_cost_num] [int] NULL,
[internal_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_cost] ON [dbo].[aud_cost] ([cost_amt], [cost_pay_rec_ind], [pos_group_num], [cost_owner_code], [cost_owner_key1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx5] ON [dbo].[aud_cost] ([cost_num], [port_num], [cost_code], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx6] ON [dbo].[aud_cost] ([cost_num], [port_num], [cost_prim_sec_ind], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx] ON [dbo].[aud_cost] ([cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx3] ON [dbo].[aud_cost] ([cost_owner_code], [cost_owner_key1], [cost_owner_key2], [cost_owner_key3], [cost_owner_key4]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx2] ON [dbo].[aud_cost] ([cost_owner_key6], [cost_owner_key7], [cost_owner_key8]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx4] ON [dbo].[aud_cost] ([parent_cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_idx1] ON [dbo].[aud_cost] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost', NULL, NULL
GO
