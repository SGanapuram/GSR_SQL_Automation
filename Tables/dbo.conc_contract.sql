CREATE TABLE [dbo].[conc_contract]
(
[oid] [int] NOT NULL,
[custom_contract_num] [int] NOT NULL,
[version_num] [int] NOT NULL,
[custom_contract_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[external_reference] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contractual_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_year] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_comp_num] [int] NULL,
[acct_num] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_brand_id] [int] NULL,
[workflow_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[traffic_operator] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cargo_conditioning] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weighing_method_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[orig_contr_qty] [float] NULL,
[total_contr_qty] [float] NULL,
[total_execution_qty] [float] NULL,
[totoal_open_contr_qty] [float] NULL,
[total_contr_min] [float] NULL,
[total_contr_max] [float] NULL,
[main_formula_num] [int] NULL,
[market_formula_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fixed_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_fixed_price] [float] NULL,
[contract_fixed_price_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_fixed_curr_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_settlement_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wsmd_insp_acct_num] [int] NULL,
[sample_lot_size] [float] NULL,
[sample_lot_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[contract_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [chk_conc_contract_p_s_ind] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [chk_conc_contract_wsmd_settlement_basis] CHECK (([wsmd_settlement_basis]='S' OR [wsmd_settlement_basis]='B' OR [wsmd_settlement_basis]='C'))
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk10] FOREIGN KEY ([cargo_conditioning]) REFERENCES [dbo].[cargo_condition] ([cargo_cond_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk11] FOREIGN KEY ([weighing_method_code]) REFERENCES [dbo].[weighing_method] ([weigh_method_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk12] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk13] FOREIGN KEY ([contract_fixed_price_uom]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk14] FOREIGN KEY ([contract_fixed_curr_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk15] FOREIGN KEY ([sample_lot_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk16] FOREIGN KEY ([contract_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk17] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk3] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk4] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk5] FOREIGN KEY ([conc_brand_id]) REFERENCES [dbo].[conc_brand] ([oid])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk6] FOREIGN KEY ([workflow_status_code]) REFERENCES [dbo].[workflow_status] ([status_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk7] FOREIGN KEY ([contract_status_code]) REFERENCES [dbo].[contract_status] ([contr_status_code])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk8] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[conc_contract] ADD CONSTRAINT [conc_contract_fk9] FOREIGN KEY ([traffic_operator]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[conc_contract] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_contract] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_contract] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_contract] TO [next_usr]
GO
