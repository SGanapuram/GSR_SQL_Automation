CREATE TABLE [dbo].[aud_qual_slate_cmdty_sptest]
(
[oid] [int] NOT NULL,
[quality_slate_id] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[is_default_test] [bit] NOT NULL CONSTRAINT [DF__aud_qual___is_de__110B679F] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qual_slate_cmdty_sptest] ON [dbo].[aud_qual_slate_cmdty_sptest] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qual_slate_cmdty_sptest_idx1] ON [dbo].[aud_qual_slate_cmdty_sptest] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_qual_slate_cmdty_sptest] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_qual_slate_cmdty_sptest] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_qual_slate_cmdty_sptest] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_qual_slate_cmdty_sptest] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_qual_slate_cmdty_sptest] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_qual_slate_cmdty_sptest', NULL, NULL
GO
