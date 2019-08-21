CREATE TABLE [dbo].[aud_fips_city]
(
[oid] [int] NOT NULL,
[fips_city_code] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fips_county_num] [int] NOT NULL,
[metro_div_title] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[csa_title] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[component_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[active_ind] [bit] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fips_city] ON [dbo].[aud_fips_city] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fips_city_idx1] ON [dbo].[aud_fips_city] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fips_city] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fips_city] TO [next_usr]
GO
