CREATE TABLE [dbo].[aud_shipment_mot]
(
[shipment_num] [int] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_mot] ON [dbo].[aud_shipment_mot] ([shipment_num], [mot_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_mot_idx1] ON [dbo].[aud_shipment_mot] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_shipment_mot] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_shipment_mot] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_shipment_mot] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_shipment_mot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_shipment_mot] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_shipment_mot', NULL, NULL
GO
