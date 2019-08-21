CREATE TABLE [dbo].[aud_vat_declaration]
(
[vat_declaration_id] [int] NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[declaration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[t1_ind] [bit] NOT NULL CONSTRAINT [df_aud_vat_declaration_t1_ind] DEFAULT ((0)),
[declaration_short_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vat_declaration_idx1] ON [dbo].[aud_vat_declaration] ([trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vat_declaration] ON [dbo].[aud_vat_declaration] ([vat_declaration_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_vat_declaration] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_vat_declaration] TO [next_usr]
GO
