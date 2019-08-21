CREATE TABLE [dbo].[fb_modular_info]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [int] NOT NULL,
[basis_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_deduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cross_ref_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_pcnt_string] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_pcnt_value] [float] NOT NULL,
[price_quote_string] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[last_computed_value] [float] NULL,
[last_computed_asof_date] [datetime] NULL,
[line_item_contr_desc] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[line_item_invoice_desc] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_start_date] [datetime] NULL,
[qp_end_date] [datetime] NULL,
[qp_election_date] [datetime] NULL,
[qp_desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_election_opt] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_elected] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_type] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qp_start_date_addl_days] [int] NULL,
[qp_end_date_addl_days] [int] NULL,
[lib_formula_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_rule_oid] [int] NULL,
[prorated_flat_amt] [float] NULL,
[qp_auto_optimize_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [chk_fb_modular_info_pay_deduct_ind] CHECK (([pay_deduct_ind]='D' OR [pay_deduct_ind]='P'))
GO
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [fb_modular_info_pk] PRIMARY KEY CLUSTERED  ([formula_num], [formula_body_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [fb_modular_info_fk1] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[fb_modular_info] ADD CONSTRAINT [fb_modular_info_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
GRANT DELETE ON  [dbo].[fb_modular_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fb_modular_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fb_modular_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fb_modular_info] TO [next_usr]
GO
