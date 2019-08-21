CREATE TABLE [dbo].[conc_brand]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[brand_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_brand] ADD CONSTRAINT [conc_brand_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_brand] ADD CONSTRAINT [conc_brand_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_brand] ADD CONSTRAINT [conc_brand_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_brand] ADD CONSTRAINT [conc_brand_fk3] FOREIGN KEY ([brand_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[conc_brand] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_brand] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_brand] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_brand] TO [next_usr]
GO
