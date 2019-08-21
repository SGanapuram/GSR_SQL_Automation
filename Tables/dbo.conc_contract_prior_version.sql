CREATE TABLE [dbo].[conc_contract_prior_version]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NULL,
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
[real_port_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[formula_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [chk_conc_contract_prior_version_p_s_ind] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk10] FOREIGN KEY ([cargo_conditioning]) REFERENCES [dbo].[cargo_condition] ([cargo_cond_code])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk11] FOREIGN KEY ([weighing_method_code]) REFERENCES [dbo].[weighing_method] ([weigh_method_code])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk14] FOREIGN KEY ([real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk15] FOREIGN KEY ([formula_num]) REFERENCES [dbo].[formula] ([formula_num])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk3] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk4] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk5] FOREIGN KEY ([conc_brand_id]) REFERENCES [dbo].[conc_brand] ([oid])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk6] FOREIGN KEY ([workflow_status_code]) REFERENCES [dbo].[workflow_status] ([status_code])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk7] FOREIGN KEY ([contract_status_code]) REFERENCES [dbo].[contract_status] ([contr_status_code])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk8] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[conc_contract_prior_version] ADD CONSTRAINT [conc_contract_prior_version_fk9] FOREIGN KEY ([traffic_operator]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[conc_contract_prior_version] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_contract_prior_version] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_contract_prior_version] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_contract_prior_version] TO [next_usr]
GO
