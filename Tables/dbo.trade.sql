CREATE TABLE [dbo].[trade]
(
[trade_num] [int] NOT NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conclusion_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inhouse_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[acct_cont_num] [int] NULL,
[acct_short_name] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_num] [int] NULL,
[concluded_date] [datetime] NULL,
[contr_approv_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_date] [datetime] NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cp_gov_contr_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_exch_method] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_cnfrm_method] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_tlx_hold_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NOT NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trade_mod_date] [datetime] NULL,
[trade_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[invoice_cap_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[internal_agreement_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_res_exp_date] [datetime] NULL,
[contr_anly_init] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_order_num] [smallint] NULL,
[is_long_term_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_is_long_term_ind] DEFAULT ('N'),
[special_contract_num] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cargo_id_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[copy_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [int] NULL,
[econfirm_status] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_trade_type] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_pricing_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[no_of_forward_months] [int] NULL,
[no_del_draw_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_mtm] [bit] NULL,
[inventory_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exch_memo_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_pk] PRIMARY KEY CLUSTERED  ([trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_idx2] ON [dbo].[trade] ([acct_num], [trade_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_TS_idx90] ON [dbo].[trade] ([creation_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_idx3] ON [dbo].[trade] ([port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_POSGRID_idx1] ON [dbo].[trade] ([trade_num]) INCLUDE ([acct_num], [contr_date], [creation_date], [inhouse_ind], [port_num], [trade_mod_date], [trader_init]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_idx1] ON [dbo].[trade] ([trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk10] FOREIGN KEY ([trade_status_code]) REFERENCES [dbo].[trade_status] ([trade_status_code])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk12] FOREIGN KEY ([product_id]) REFERENCES [dbo].[icts_product] ([product_id])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk2] FOREIGN KEY ([acct_num], [acct_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk3] FOREIGN KEY ([contr_status_code]) REFERENCES [dbo].[contract_status] ([contr_status_code])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk4] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk5] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk6] FOREIGN KEY ([cr_anly_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk7] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade] ADD CONSTRAINT [trade_fk8] FOREIGN KEY ([trade_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade] TO [next_usr]
GO
