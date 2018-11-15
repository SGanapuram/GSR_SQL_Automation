CREATE TABLE [dbo].[aud_conc_exec_assay]
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
[resp_trans_id] [int] NOT NULL,
[line_num] [int] NULL,
[result_date] [datetime] NULL,
[assay_lab_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_exec_weight_oid] [int] NULL,
[use_in_hedge_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[conc_ref_result_type_oid] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_exec_assay] ON [dbo].[aud_conc_exec_assay] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_exec_assay_idx1] ON [dbo].[aud_conc_exec_assay] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_exec_assay] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_exec_assay] TO [next_usr]
GO
