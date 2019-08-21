CREATE TABLE [dbo].[shipment_path]
(
[shipment_oid] [int] NOT NULL,
[path_oid] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shipment_path] ADD CONSTRAINT [shipment_path_pk] PRIMARY KEY CLUSTERED  ([shipment_oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[shipment_path] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[shipment_path] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[shipment_path] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[shipment_path] TO [next_usr]
GO
