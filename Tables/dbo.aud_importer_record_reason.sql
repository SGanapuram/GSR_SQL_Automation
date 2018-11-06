CREATE TABLE [dbo].[aud_importer_record_reason]
(
[oid] [int] NOT NULL,
[reason] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_importer_record_reason] ON [dbo].[aud_importer_record_reason] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_imp_record_reason_idx1] ON [dbo].[aud_importer_record_reason] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_importer_record_reason] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_importer_record_reason] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_importer_record_reason] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_importer_record_reason] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_importer_record_reason] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_importer_record_reason', NULL, NULL
GO
