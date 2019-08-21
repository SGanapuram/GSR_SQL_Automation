CREATE TABLE [dbo].[aud_license]
(
[license_num] [int] NOT NULL,
[issuing_tax_authority_num] [int] NOT NULL,
[license_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[license_eff_date] [datetime] NULL,
[license_exp_date] [datetime] NULL,
[license_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_license] ON [dbo].[aud_license] ([license_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_license_idx1] ON [dbo].[aud_license] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_license] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_license] TO [next_usr]
GO
