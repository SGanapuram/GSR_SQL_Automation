CREATE TABLE [dbo].[aud_path_segment]
(
[path_oid] [int] NOT NULL,
[segment_oid] [int] NOT NULL,
[path_sequence] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_path_segment] ON [dbo].[aud_path_segment] ([path_oid], [segment_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_path_segment_idx1] ON [dbo].[aud_path_segment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_path_segment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_path_segment] TO [next_usr]
GO
