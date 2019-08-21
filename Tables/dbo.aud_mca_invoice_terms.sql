CREATE TABLE [dbo].[aud_mca_invoice_terms]
(
[invoice_num] [int] NOT NULL,
[contact_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contact_phone_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contact_telex_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cutoff_date] [datetime] NULL,
[email] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[enable_email] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[coll_party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_invoice_terms] ON [dbo].[aud_mca_invoice_terms] ([invoice_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mca_invoice_terms_idx1] ON [dbo].[aud_mca_invoice_terms] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_mca_invoice_terms] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mca_invoice_terms] TO [next_usr]
GO
