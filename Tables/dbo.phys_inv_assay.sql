CREATE TABLE [dbo].[phys_inv_assay]
(
[exec_inv_num] [int] NOT NULL,
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
[trans_id] [int] NOT NULL,
[use_in_pl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_assay_oid] [int] NULL,
[owner_assay] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_assay] ADD CONSTRAINT [phys_inv_assay_pk] PRIMARY KEY CLUSTERED  ([exec_inv_num], [assay_group_num], [assay_date], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_assay] ADD CONSTRAINT [phys_inv_assay_fk1] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
GRANT DELETE ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[phys_inv_assay] TO [next_usr]
GO
