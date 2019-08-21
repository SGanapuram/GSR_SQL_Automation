CREATE TABLE [dbo].[aud_folder_document]
(
[folder_num] [int] NOT NULL,
[doc_num] [int] NOT NULL,
[doc_rev_num] [smallint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_folder_document] ON [dbo].[aud_folder_document] ([folder_num], [doc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_folder_document_idx1] ON [dbo].[aud_folder_document] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_folder_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_folder_document] TO [next_usr]
GO
