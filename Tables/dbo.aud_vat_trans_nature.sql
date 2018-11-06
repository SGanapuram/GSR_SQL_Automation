CREATE TABLE [dbo].[aud_vat_trans_nature]
(
[trans_nature_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_nature_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vat_trans_nature_idx1] ON [dbo].[aud_vat_trans_nature] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vat_trans_nature] ON [dbo].[aud_vat_trans_nature] ([trans_nature_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_vat_trans_nature] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_vat_trans_nature] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_vat_trans_nature] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_vat_trans_nature] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_vat_trans_nature] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_vat_trans_nature', NULL, NULL
GO
