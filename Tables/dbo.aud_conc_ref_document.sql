CREATE TABLE [dbo].[aud_conc_ref_document]
(
[oid] [int] NOT NULL,
[document_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_desc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_document] ON [dbo].[aud_conc_ref_document] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_conc_ref_document_idx1] ON [dbo].[aud_conc_ref_document] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_conc_ref_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_conc_ref_document] TO [next_usr]
GO
