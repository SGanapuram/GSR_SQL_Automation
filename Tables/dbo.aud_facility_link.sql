CREATE TABLE [dbo].[aud_facility_link]
(
[oid] [int] NOT NULL,
[upstream_facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[downstream_facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_link] ON [dbo].[aud_facility_link] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_facility_link_idx1] ON [dbo].[aud_facility_link] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_facility_link] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_facility_link] TO [next_usr]
GO
