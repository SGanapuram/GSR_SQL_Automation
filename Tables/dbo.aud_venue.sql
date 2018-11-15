CREATE TABLE [dbo].[aud_venue]
(
[id] [int] NOT NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_venue] ON [dbo].[aud_venue] ([id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_venue_idx1] ON [dbo].[aud_venue] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_venue] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_venue] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_venue] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_venue] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_venue] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_venue', NULL, NULL
GO
