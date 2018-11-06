CREATE TABLE [dbo].[aud_fips_state]
(
[oid] [int] NOT NULL,
[state_abbr] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fips_state_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[state_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[active_ind] [bit] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fips_state] ON [dbo].[aud_fips_state] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fips_state_idx1] ON [dbo].[aud_fips_state] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_fips_state] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_fips_state] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_fips_state] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_fips_state] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fips_state] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_fips_state', NULL, NULL
GO
