CREATE TABLE [dbo].[aud_release_document]
(
[release_doc_num] [int] NOT NULL,
[trade_num] [int] NULL,
[selling_office_addr_num] [int] NULL,
[release_printed_ind] [bit] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_release_document] ON [dbo].[aud_release_document] ([release_doc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_release_document_idx1] ON [dbo].[aud_release_document] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_release_document] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_release_document] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_release_document] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_release_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_release_document] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_release_document', NULL, NULL
GO
