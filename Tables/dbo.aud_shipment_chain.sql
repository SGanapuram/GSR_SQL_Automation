CREATE TABLE [dbo].[aud_shipment_chain]
(
[shipment_num] [int] NOT NULL,
[next_shipment_num] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_chain] ON [dbo].[aud_shipment_chain] ([shipment_num], [next_shipment_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_chain_idx1] ON [dbo].[aud_shipment_chain] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_shipment_chain] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_shipment_chain] TO [next_usr]
GO
