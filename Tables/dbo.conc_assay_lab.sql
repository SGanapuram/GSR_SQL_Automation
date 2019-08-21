CREATE TABLE [dbo].[conc_assay_lab]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[assay_lab_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[final_binding_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[umpire_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_assay_lab] ADD CONSTRAINT [chk_conc_assay_lab_final_binding_ind] CHECK (([final_binding_ind]='N' OR [final_binding_ind]='Y'))
GO
ALTER TABLE [dbo].[conc_assay_lab] ADD CONSTRAINT [chk_conc_assay_lab_umpire_ind] CHECK (([umpire_ind]='N' OR [umpire_ind]='Y'))
GO
ALTER TABLE [dbo].[conc_assay_lab] ADD CONSTRAINT [conc_assay_lab_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_assay_lab] ADD CONSTRAINT [conc_assay_lab_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_assay_lab] ADD CONSTRAINT [conc_assay_lab_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_assay_lab] ADD CONSTRAINT [conc_assay_lab_fk3] FOREIGN KEY ([assay_lab_code]) REFERENCES [dbo].[assay_lab] ([assay_lab_code])
GO
GRANT DELETE ON  [dbo].[conc_assay_lab] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_assay_lab] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_assay_lab] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_assay_lab] TO [next_usr]
GO
