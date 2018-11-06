CREATE TABLE [dbo].[aud_time_zone]
(
[time_zone_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[time_zone_offset] [int] NOT NULL,
[time_zone_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_time_zone] ON [dbo].[aud_time_zone] ([time_zone_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_time_zone_idx1] ON [dbo].[aud_time_zone] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_time_zone] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_time_zone] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_time_zone] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_time_zone] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_time_zone] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_time_zone', NULL, NULL
GO
