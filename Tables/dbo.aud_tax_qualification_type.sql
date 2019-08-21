CREATE TABLE [dbo].[aud_tax_qualification_type]
(
[code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_qualification_ty_idx1] ON [dbo].[aud_tax_qualification_type] ([code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_qualification_ty_idx2] ON [dbo].[aud_tax_qualification_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_tax_qualification_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tax_qualification_type] TO [next_usr]
GO
