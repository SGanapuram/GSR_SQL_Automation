CREATE TABLE [dbo].[aud_fips_county]
(
[oid] [int] NOT NULL,
[fips_state_num] [int] NOT NULL,
[fips_county_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[county_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[active_ind] [bit] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fips_county] ON [dbo].[aud_fips_county] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fips_county_idx1] ON [dbo].[aud_fips_county] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fips_county] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fips_county] TO [next_usr]
GO
