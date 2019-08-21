CREATE TABLE [dbo].[aud_shipment_status]
(
[oid] [int] NOT NULL,
[status_description] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status_ind] [tinyint] NOT NULL,
[status_workflow_rank] [tinyint] NOT NULL,
[enable_profit_loss] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_status] ON [dbo].[aud_shipment_status] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_status_idx1] ON [dbo].[aud_shipment_status] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_shipment_status] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_shipment_status] TO [next_usr]
GO
