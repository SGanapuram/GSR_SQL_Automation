CREATE TABLE [dbo].[aud_ag_nomination_line_item]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[pipeline_event_type] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[location_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[consignee_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tankage_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[supplier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_start_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[shipment_id] [int] NULL,
[parcel_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_nomination_line_item] ON [dbo].[aud_ag_nomination_line_item] ([fdd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_nomination_line_item_idx1] ON [dbo].[aud_ag_nomination_line_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ag_nomination_line_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_nomination_line_item] TO [next_usr]
GO
