CREATE TABLE [dbo].[parcel_quality_slate]
(
[oid] [int] NOT NULL,
[parcel_id] [int] NOT NULL,
[quality_slate_id] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parcel_quality_slate] ADD CONSTRAINT [parcel_quality_slate_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parcel_quality_slate] ADD CONSTRAINT [parcel_quality_slate_fk1] FOREIGN KEY ([quality_slate_id]) REFERENCES [dbo].[quality_slate] ([oid])
GO
GRANT DELETE ON  [dbo].[parcel_quality_slate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parcel_quality_slate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parcel_quality_slate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parcel_quality_slate] TO [next_usr]
GO
