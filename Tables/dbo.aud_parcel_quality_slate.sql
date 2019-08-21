CREATE TABLE [dbo].[aud_parcel_quality_slate]
(
[oid] [int] NOT NULL,
[parcel_id] [int] NOT NULL,
[quality_slate_id] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parcel_quality_slate] ON [dbo].[aud_parcel_quality_slate] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parcel_quality_slate_idx1] ON [dbo].[aud_parcel_quality_slate] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_parcel_quality_slate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parcel_quality_slate] TO [next_usr]
GO
