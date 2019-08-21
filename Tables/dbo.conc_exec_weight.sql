CREATE TABLE [dbo].[conc_exec_weight]
(
[oid] [int] NOT NULL,
[contract_execution_oid] [int] NOT NULL,
[measure_date] [datetime] NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_qty] [float] NULL,
[prim_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_qty] [float] NULL,
[sec_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_pl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[weight_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weight_detail_num] [int] NULL,
[group_num] [int] NULL,
[line_num] [int] NULL,
[result_date] [datetime] NULL,
[conc_ref_document_oid] [int] NULL,
[title_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[moisture_percent] [float] NULL,
[franchise_percent] [float] NULL,
[insp_acct_num] [int] NULL,
[final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_ref_result_type_oid] [int] NULL,
[cargo_condition_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [chk_conc_exec_weight_final_ind] CHECK (([final_ind]='N' OR [final_ind]='Y'))
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [chk_conc_exec_weight_title_ind] CHECK (([title_ind]='N' OR [title_ind]='Y'))
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk1] FOREIGN KEY ([contract_execution_oid]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk2] FOREIGN KEY ([conc_ref_document_oid]) REFERENCES [dbo].[conc_ref_document] ([oid])
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk3] FOREIGN KEY ([insp_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk4] FOREIGN KEY ([loc_type_code]) REFERENCES [dbo].[location_type] ([loc_type_code])
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk5] FOREIGN KEY ([loc_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk6] FOREIGN KEY ([conc_ref_result_type_oid]) REFERENCES [dbo].[conc_ref_result_type] ([oid])
GO
ALTER TABLE [dbo].[conc_exec_weight] ADD CONSTRAINT [conc_exec_weight_fk7] FOREIGN KEY ([cargo_condition_code]) REFERENCES [dbo].[cargo_condition] ([cargo_cond_code])
GO
GRANT DELETE ON  [dbo].[conc_exec_weight] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_exec_weight] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_exec_weight] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_exec_weight] TO [next_usr]
GO
