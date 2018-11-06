CREATE TABLE [dbo].[aud_lic_tax_implication]
(
[license_num] [int] NOT NULL,
[license_covers_num] [int] NOT NULL,
[tax_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tax_exempt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax_rate_discount] [float] NULL,
[product_usage_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lic_tax_implication] ON [dbo].[aud_lic_tax_implication] ([license_num], [license_covers_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_lic_tax_implication_idx1] ON [dbo].[aud_lic_tax_implication] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_lic_tax_implication] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_lic_tax_implication] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_lic_tax_implication] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_lic_tax_implication] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_lic_tax_implication] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_lic_tax_implication', NULL, NULL
GO
