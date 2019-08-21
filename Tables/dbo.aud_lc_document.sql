CREATE TABLE [dbo].[aud_lc_document]
(
[lc_num] [int] NOT NULL,
[lc_doc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_doc_copy_num] [tinyint] NULL,
[lc_no_of_orig_doc_reqd] [tinyint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_document] ON [dbo].[aud_lc_document] ([lc_num], [lc_doc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_document_idx1] ON [dbo].[aud_lc_document] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_document] TO [next_usr]
GO
