CREATE TABLE [dbo].[conc_exec_assay]
(
[oid] [int] NOT NULL,
[contract_execution_oid] [int] NOT NULL,
[assay_group_num] [int] NOT NULL,
[assay_date] [datetime] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[spec_actual_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_opt_val] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_provisional_val] [float] NULL,
[spec_provisional_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_provisiional_opt_val] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_pl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[line_num] [int] NULL,
[result_date] [datetime] NULL,
[assay_lab_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_exec_weight_oid] [int] NULL,
[use_in_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_ref_result_type_oid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_exec_assay] ADD CONSTRAINT [chk_conc_exec_assay_use_in_hedge_ind] CHECK (([use_in_hedge_ind]='N' OR [use_in_hedge_ind]='Y'))
GO
ALTER TABLE [dbo].[conc_exec_assay] ADD CONSTRAINT [conc_exec_assay_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_exec_assay] ADD CONSTRAINT [conc_exec_assay_fk1] FOREIGN KEY ([contract_execution_oid]) REFERENCES [dbo].[contract_execution] ([oid])
GO
ALTER TABLE [dbo].[conc_exec_assay] ADD CONSTRAINT [conc_exec_assay_fk2] FOREIGN KEY ([assay_lab_code]) REFERENCES [dbo].[assay_lab] ([assay_lab_code])
GO
ALTER TABLE [dbo].[conc_exec_assay] ADD CONSTRAINT [conc_exec_assay_fk3] FOREIGN KEY ([conc_exec_weight_oid]) REFERENCES [dbo].[conc_exec_weight] ([oid])
GO
ALTER TABLE [dbo].[conc_exec_assay] ADD CONSTRAINT [conc_exec_assay_fk4] FOREIGN KEY ([conc_ref_result_type_oid]) REFERENCES [dbo].[conc_ref_result_type] ([oid])
GO
GRANT DELETE ON  [dbo].[conc_exec_assay] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_exec_assay] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_exec_assay] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_exec_assay] TO [next_usr]
GO
