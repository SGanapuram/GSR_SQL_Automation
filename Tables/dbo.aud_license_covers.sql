CREATE TABLE [dbo].[aud_license_covers]
(
[license_num] [int] NOT NULL,
[license_covers_num] [int] NOT NULL,
[tax_authority_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_license_covers] ON [dbo].[aud_license_covers] ([license_num], [license_covers_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_license_covers_idx1] ON [dbo].[aud_license_covers] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_license_covers] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_license_covers] TO [next_usr]
GO
