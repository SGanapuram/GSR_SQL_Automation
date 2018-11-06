CREATE TABLE [dbo].[aud_voyage]
(
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voyage_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[voyage_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_voyage_idx] ON [dbo].[aud_voyage] ([voyage_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_voyage] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_voyage] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_voyage] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_voyage] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_voyage] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_voyage', NULL, NULL
GO
