CREATE TABLE [dbo].[aud_tax_location]
(
[tax_authority_num] [int] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_location] ON [dbo].[aud_tax_location] ([tax_authority_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tax_location_idx1] ON [dbo].[aud_tax_location] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_tax_location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tax_location] TO [next_usr]
GO
