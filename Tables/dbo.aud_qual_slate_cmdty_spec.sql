CREATE TABLE [dbo].[aud_qual_slate_cmdty_spec]
(
[oid] [int] NOT NULL,
[quality_slate_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmdty_spec_min_val] [numeric] (20, 8) NULL,
[cmdty_spec_max_val] [numeric] (20, 8) NULL,
[cmdty_spec_typical_val] [numeric] (20, 8) NULL,
[mandatory_ind] [bit] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[typical_string_value] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qual_slate_cmdty_spec] ON [dbo].[aud_qual_slate_cmdty_spec] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qual_slate_cmdty_spec_idx1] ON [dbo].[aud_qual_slate_cmdty_spec] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_qual_slate_cmdty_spec] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_qual_slate_cmdty_spec] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_qual_slate_cmdty_spec] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_qual_slate_cmdty_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_qual_slate_cmdty_spec] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_qual_slate_cmdty_spec', NULL, NULL
GO
