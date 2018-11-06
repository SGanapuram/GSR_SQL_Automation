CREATE TABLE [dbo].[aud_cost_ext_info]
(
[cost_num] [int] NOT NULL,
[pr_cost_num] [int] NULL,
[prepayment_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[qty_adj_rule_num] [int] NULL,
[qty_adj_factor] [float] NULL,
[orig_voucher_num] [int] NULL,
[pay_term_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vat_rate] [numeric] (12, 6) NULL,
[discount_rate] [numeric] (12, 6) NULL,
[cost_pl_contribution_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[material_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[related_cost_num] [int] NULL,
[fx_exp_num] [int] NULL,
[creation_fx_rate] [numeric] (20, 8) NULL,
[creation_rate_m_d_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__aud_cost___creat__0BBCA29D] DEFAULT ('M'),
[fx_link_oid] [int] NULL,
[fx_locking_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__aud_cost___fx_lo__0CB0C6D6] DEFAULT ('N'),
[fx_compute_ind] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_real_port_num] [int] NULL,
[reserve_cost_amt] [numeric] (20, 8) NULL,
[pl_contrib_mod_transid] [int] NULL,
[manual_input_pl_contrib_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__aud_cost___manua__0DA4EB0F] DEFAULT ('N'),
[cost_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_cover_num] [int] NULL,
[prelim_type_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_ext_info_idx] ON [dbo].[aud_cost_ext_info] ([cost_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_ext_info_idx1] ON [dbo].[aud_cost_ext_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_ext_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_ext_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_ext_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_ext_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_ext_info', NULL, NULL
GO
