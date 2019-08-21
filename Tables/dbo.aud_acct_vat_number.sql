CREATE TABLE [dbo].[aud_acct_vat_number]
(
[acct_vat_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[vat_type_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[vat_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_vat_number] ON [dbo].[aud_acct_vat_number] ([acct_vat_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_vat_number_idx1] ON [dbo].[aud_acct_vat_number] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_vat_number] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_vat_number] TO [next_usr]
GO
