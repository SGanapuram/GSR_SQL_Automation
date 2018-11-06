CREATE TABLE [dbo].[aud_uic_report_type]
(
[oid] [int] NOT NULL,
[report_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_report_type] ON [dbo].[aud_uic_report_type] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_uic_report_type_idx1] ON [dbo].[aud_uic_report_type] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_uic_report_type] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_uic_report_type] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_uic_report_type] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_uic_report_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_uic_report_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_uic_report_type', NULL, NULL
GO
