CREATE TABLE [dbo].[conc_del_term]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[term_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL,
[loc_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [chk_conc_del_term_term_type] CHECK (([term_type]='D' OR [term_type]='W'))
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [conc_del_term_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [conc_del_term_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [conc_del_term_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [conc_del_term_fk3] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [conc_del_term_fk4] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[conc_del_term] ADD CONSTRAINT [conc_del_term_fk5] FOREIGN KEY ([loc_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
GRANT DELETE ON  [dbo].[conc_del_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_del_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_del_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_del_term] TO [next_usr]
GO
