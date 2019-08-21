CREATE TABLE [dbo].[aud_sap_confirmation]
(
[voucher_num] [int] NOT NULL,
[sap_document_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_post_datetime] [datetime] NULL,
[filename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[icts_post_datetime] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_sap_confirmation_idx1] ON [dbo].[aud_sap_confirmation] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_sap_confirmation] ON [dbo].[aud_sap_confirmation] ([voucher_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_sap_confirmation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_sap_confirmation] TO [next_usr]
GO
