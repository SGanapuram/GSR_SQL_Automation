CREATE TABLE [dbo].[aud_lc_item_document]
(
[lc_num] [int] NOT NULL,
[lc_alloc_num] [tinyint] NOT NULL,
[lc_item_num] [tinyint] NOT NULL,
[lc_doc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_item_doc_ref] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_item_doc_copy_num] [tinyint] NULL,
[lc_item_doc_rcvd_date] [datetime] NULL,
[lc_item_doc_present_date] [datetime] NULL,
[lc_item_doc_change_date] [datetime] NULL,
[lc_item_doc_confirm_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_item_document] ON [dbo].[aud_lc_item_document] ([lc_num], [lc_alloc_num], [lc_item_num], [lc_doc_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lc_item_document_idx1] ON [dbo].[aud_lc_item_document] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_lc_item_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lc_item_document] TO [next_usr]
GO
