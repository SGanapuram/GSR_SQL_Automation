CREATE TABLE [dbo].[conc_assay]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[conc_prior_ver_oid] [int] NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[per_spec_uom_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_min_value] [float] NULL,
[spec_min_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_max_value] [float] NULL,
[spec_max_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_typical_value] [float] NULL,
[spec_typical_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_regulatory_limit] [float] NULL,
[spec_regulatory_limit_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[secondary_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[row_order_num] [int] NULL,
[analysis_basis] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[umpire_rule] [int] NULL,
[sl_applicable] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[splitting_limit] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_assay] ADD CONSTRAINT [conc_assay_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_assay] ADD CONSTRAINT [conc_assay_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_assay] ADD CONSTRAINT [conc_assay_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_assay] ADD CONSTRAINT [conc_assay_fk3] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[conc_assay] ADD CONSTRAINT [conc_assay_fk4] FOREIGN KEY ([spec_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[conc_assay] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_assay] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_assay] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_assay] TO [next_usr]
GO
