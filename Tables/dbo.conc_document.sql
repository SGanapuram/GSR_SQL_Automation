CREATE TABLE [dbo].[conc_document]
(
[oid] [int] NOT NULL,
[conc_contract_oid] [int] NOT NULL,
[version_num] [smallint] NULL,
[conc_prior_ver_oid] [int] NULL,
[doc_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_mod_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[doc_creation_date] [datetime] NOT NULL,
[doc_last_mod_date] [datetime] NULL,
[doc_url] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_document] ADD CONSTRAINT [conc_document_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conc_document] ADD CONSTRAINT [conc_document_fk1] FOREIGN KEY ([conc_contract_oid]) REFERENCES [dbo].[conc_contract] ([oid])
GO
ALTER TABLE [dbo].[conc_document] ADD CONSTRAINT [conc_document_fk2] FOREIGN KEY ([conc_prior_ver_oid]) REFERENCES [dbo].[conc_contract_prior_version] ([oid])
GO
ALTER TABLE [dbo].[conc_document] ADD CONSTRAINT [conc_document_fk3] FOREIGN KEY ([doc_creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[conc_document] ADD CONSTRAINT [conc_document_fk4] FOREIGN KEY ([doc_mod_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[conc_document] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[conc_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[conc_document] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[conc_document] TO [next_usr]
GO
