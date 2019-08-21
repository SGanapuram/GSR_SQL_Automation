CREATE TABLE [dbo].[aud_document]
(
[doc_num] [int] NOT NULL,
[doc_rev_num] [smallint] NOT NULL,
[doc_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_status_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[doc_owner_key1] [int] NOT NULL,
[doc_owner_key2] [int] NULL,
[doc_owner_key3] [int] NULL,
[doc_owner_key4] [int] NULL,
[doc_owner_key5] [int] NULL,
[doc_owner_key6] [int] NULL,
[doc_owner_key7] [int] NULL,
[doc_owner_key8] [int] NULL,
[doc_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[doc_creation_date] [datetime] NOT NULL,
[doc_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_document] ON [dbo].[aud_document] ([doc_num], [doc_rev_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_document_idx1] ON [dbo].[aud_document] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_document] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_document] TO [next_usr]
GO
