CREATE TABLE [dbo].[aud_document_message]
(
[doc_num] [int] NOT NULL,
[doc_rev_num] [smallint] NOT NULL,
[doc_msg_num] [smallint] NOT NULL,
[doc_msg_data] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_document_message] ON [dbo].[aud_document_message] ([doc_num], [doc_rev_num], [doc_msg_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_document_message_idx1] ON [dbo].[aud_document_message] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_document_message] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_document_message] TO [next_usr]
GO
