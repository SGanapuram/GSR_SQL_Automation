CREATE TABLE [dbo].[cost_ext_info]
(
[cost_num] [int] NOT NULL,
[pr_cost_num] [int] NULL,
[prepayment_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[qty_adj_rule_num] [int] NULL,
[qty_adj_factor] [float] NULL,
[orig_voucher_num] [int] NULL,
[pay_term_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_rate] [numeric] (12, 6) NULL,
[discount_rate] [numeric] (12, 6) NULL,
[cost_pl_contribution_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_cost_ext_info_cost_pl_contribution_ind] DEFAULT ('Y'),
[material_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[related_cost_num] [int] NULL,
[fx_exp_num] [int] NULL,
[creation_fx_rate] [numeric] (20, 8) NULL,
[creation_rate_m_d_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_cost_ext_info_creation_rate_m_d_ind] DEFAULT ('M'),
[fx_link_oid] [int] NULL,
[fx_locking_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_cost_ext_info_fx_locking_status] DEFAULT ('N'),
[fx_compute_ind] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_real_port_num] [int] NULL,
[reserve_cost_amt] [numeric] (20, 8) NULL,
[pl_contrib_mod_transid] [int] NULL,
[manual_input_pl_contrib_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_cost_ext_info_manual_input_pl_contrib_ind] DEFAULT ('N'),
[cost_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_cover_num] [int] NULL,
[prelim_type_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [chk_cost_ext_info_cost_pl_contribution_ind] CHECK (([cost_pl_contribution_ind]='N' OR [cost_pl_contribution_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [chk_cost_ext_info_creation_rate_m_d_ind] CHECK (([creation_rate_m_d_ind]='D' OR [creation_rate_m_d_ind]='M'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [chk_cost_ext_info_fx_locking_status] CHECK (([fx_locking_status]='L' OR [fx_locking_status]='U' OR [fx_locking_status]='O' OR [fx_locking_status]='N'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [chk_cost_ext_info_manual_input_pl_contrib_ind] CHECK (([manual_input_pl_contrib_ind]='N' OR [manual_input_pl_contrib_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [chk_cost_ext_info_prelim_type_override_ind] CHECK (([prelim_type_override_ind]='N' OR [prelim_type_override_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cost_ext_info_idx1] ON [dbo].[cost_ext_info] ([cost_num], [cost_pl_contribution_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cost_ext_info_idx2] ON [dbo].[cost_ext_info] ([fx_exp_num], [cost_pl_contribution_ind]) INCLUDE ([cost_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk3] FOREIGN KEY ([voyage_code]) REFERENCES [dbo].[voyage] ([voyage_code])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk6] FOREIGN KEY ([fx_real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk7] FOREIGN KEY ([fx_link_oid]) REFERENCES [dbo].[fx_linking] ([oid])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk8] FOREIGN KEY ([fx_exp_num]) REFERENCES [dbo].[fx_exposure] ([oid])
GO
ALTER TABLE [dbo].[cost_ext_info] ADD CONSTRAINT [cost_ext_info_fk9] FOREIGN KEY ([risk_cover_num]) REFERENCES [dbo].[risk_cover] ([risk_cover_num])
GO
GRANT DELETE ON  [dbo].[cost_ext_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_ext_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_ext_info] TO [next_usr]
GO
