CREATE TABLE [dbo].[conc_assay_activity]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[assay_activity_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[target] [int] NOT NULL,
[time] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[activity_trigger] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_assay_activity] ADD CONSTRAINT [conc_assay_activity_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_assay_activity] ADD CONSTRAINT [conc_assay_activity_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_assay_activity] ADD CONSTRAINT [conc_assay_activity_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_assay_activity] ADD CONSTRAINT [conc_assay_activity_fk3] FOREIGN KEY ([assay_activity_code]) REFERENCES [dbo].[assay_activity] ([activity_code])
GO
GRANT DELETE ON  [dbo].[conc_assay_activity] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_assay_activity] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_assay_activity] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_assay_activity] TO [next_usr]
GO
