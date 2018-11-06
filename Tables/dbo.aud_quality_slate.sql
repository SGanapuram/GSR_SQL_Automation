CREATE TABLE [dbo].[aud_quality_slate]
(
[oid] [int] NOT NULL,
[code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_default_slate] [bit] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quality_slate] ON [dbo].[aud_quality_slate] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_quality_slate_idx1] ON [dbo].[aud_quality_slate] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_quality_slate] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_quality_slate] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_quality_slate] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_quality_slate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_quality_slate] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_quality_slate', NULL, NULL
GO
