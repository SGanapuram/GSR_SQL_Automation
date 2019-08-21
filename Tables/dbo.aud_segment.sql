CREATE TABLE [dbo].[aud_segment]
(
[oid] [int] NOT NULL,
[segment_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[facility_link_oid] [int] NOT NULL,
[transit_time] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_segment] ON [dbo].[aud_segment] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_segment_idx1] ON [dbo].[aud_segment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_segment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_segment] TO [next_usr]
GO
