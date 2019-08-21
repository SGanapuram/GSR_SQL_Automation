CREATE TABLE [dbo].[cost]
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
[bus_cost_fate_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
[cost_center_code_debt] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_center_code_credit] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_send_id] [smallint] NULL,
[vc_acct_num] [int] NULL,
[cash_date] [datetime] NULL,
[po_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[eff_date_override_trans_id] [int] NULL,
[finance_bank_num] [int] NULL,
[tax_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_ref_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_rate_oid] [int] NULL,
[template_cost_num] [int] NULL,
[internal_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[user_mod_date] [datetime] NULL,
[summary_cost_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [chk_cost_internal_cost_ind] CHECK (([internal_cost_ind]='N' OR [internal_cost_ind]='Y'))
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_owner_idx] ON [dbo].[cost] ([cost_owner_code], [cost_owner_key1], [cost_owner_key2], [cost_owner_key3], [cost_owner_key4]) INCLUDE ([cost_status], [cost_type_code], [template_cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx2] ON [dbo].[cost] ([cost_owner_key6], [cost_owner_key7], [cost_owner_key8]) INCLUDE ([cost_amt], [cost_pay_rec_ind], [cost_prim_sec_ind], [cost_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx3] ON [dbo].[cost] ([cost_type_code], [cost_owner_key1], [cost_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx5] ON [dbo].[cost] ([parent_cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx4] ON [dbo].[cost] ([port_num], [cost_amt_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_idx6] ON [dbo].[cost] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk10] FOREIGN KEY ([cost_center_code_credit]) REFERENCES [dbo].[cost_center] ([cost_center_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk11] FOREIGN KEY ([cost_owner_code]) REFERENCES [dbo].[cost_owner] ([cost_owner_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk12] FOREIGN KEY ([cost_status]) REFERENCES [dbo].[cost_status] ([cost_status_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk13] FOREIGN KEY ([cost_type_code]) REFERENCES [dbo].[cost_type] ([cost_type_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk14] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk15] FOREIGN KEY ([bus_cost_fate_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk16] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk17] FOREIGN KEY ([cost_due_date_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk18] FOREIGN KEY ([cost_approval_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk19] FOREIGN KEY ([cost_gl_acct_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk2] FOREIGN KEY ([cost_book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk20] FOREIGN KEY ([cost_gl_book_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk21] FOREIGN KEY ([cost_price_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk22] FOREIGN KEY ([pay_method_code]) REFERENCES [dbo].[payment_method] ([pay_method_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk23] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk26] FOREIGN KEY ([cost_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk27] FOREIGN KEY ([cost_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk29] FOREIGN KEY ([finance_bank_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk3] FOREIGN KEY ([bus_cost_fate_num]) REFERENCES [dbo].[bus_cost_fate] ([bc_fate_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk30] FOREIGN KEY ([tax_status_code]) REFERENCES [dbo].[tax_status] ([tax_status_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk31] FOREIGN KEY ([cost_rate_oid]) REFERENCES [dbo].[cost_rate] ([oid])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk32] FOREIGN KEY ([template_cost_num]) REFERENCES [dbo].[cost] ([cost_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk4] FOREIGN KEY ([bus_cost_state_num]) REFERENCES [dbo].[bus_cost_state] ([bc_state_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk5] FOREIGN KEY ([bus_cost_type_num]) REFERENCES [dbo].[bus_cost_type] ([bc_type_num])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk7] FOREIGN KEY ([cost_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk8] FOREIGN KEY ([cost_book_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[cost] ADD CONSTRAINT [cost_fk9] FOREIGN KEY ([cost_center_code_debt]) REFERENCES [dbo].[cost_center] ([cost_center_code])
GO
GRANT DELETE ON  [dbo].[cost] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost] TO [next_usr]
GO
