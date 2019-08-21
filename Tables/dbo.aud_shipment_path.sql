CREATE TABLE [dbo].[aud_shipment_path]
(
[shipment_oid] [int] NOT NULL,
[path_oid] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_path] ON [dbo].[aud_shipment_path] ([shipment_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_path_idx1] ON [dbo].[aud_shipment_path] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_shipment_path] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_shipment_path] TO [next_usr]
GO
