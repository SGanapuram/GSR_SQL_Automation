CREATE TABLE [dbo].[aud_desk_location]
(
[desk_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[desk_loc_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_desk_location] ON [dbo].[aud_desk_location] ([desk_code], [loc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_desk_location_idx1] ON [dbo].[aud_desk_location] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_desk_location] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_desk_location] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_desk_location] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_desk_location] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_desk_location] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_desk_location', NULL, NULL
GO
