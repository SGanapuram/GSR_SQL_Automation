CREATE TABLE [dbo].[aud_conc_document]
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
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_document] ON [dbo].[aud_conc_document] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_document_idx1] ON [dbo].[aud_conc_document] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_document] TO [next_usr]
GO
