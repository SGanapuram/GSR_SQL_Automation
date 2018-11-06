CREATE TABLE [dbo].[aud_path]
(
[oid] [int] NOT NULL,
[path_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[discharge_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[default_path_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[tot_transit_time] [datetime] NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_path] ON [dbo].[aud_path] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_path_idx1] ON [dbo].[aud_path] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_path] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_path] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_path] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_path] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_path] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_path', NULL, NULL
GO
