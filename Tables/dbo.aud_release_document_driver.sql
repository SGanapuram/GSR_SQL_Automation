CREATE TABLE [dbo].[aud_release_document_driver]
(
[oid] [int] NOT NULL,
[release_doc_num] [int] NOT NULL,
[driver_name] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[license_number] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[registration_id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[truck_type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_release_document_driver] ON [dbo].[aud_release_document_driver] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_release_doc_driver_idx1] ON [dbo].[aud_release_document_driver] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_release_document_driver] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_release_document_driver] TO [next_usr]
GO
