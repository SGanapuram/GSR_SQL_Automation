CREATE TABLE [dbo].[aud_vat_type]
(
[vat_type_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[vat_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[vat_type_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vat_type_idx1] ON [dbo].[aud_vat_type] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vat_type] ON [dbo].[aud_vat_type] ([vat_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_vat_type] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_vat_type] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_vat_type] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_vat_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_vat_type] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_vat_type', NULL, NULL
GO
