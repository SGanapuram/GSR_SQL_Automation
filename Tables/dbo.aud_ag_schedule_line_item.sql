CREATE TABLE [dbo].[aud_ag_schedule_line_item]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[batch_number] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pipeline_event_type] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[location_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pipeline_cycle] [int] NOT NULL,
[pipeline_sequence] [int] NOT NULL,
[pipeline_scd] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[supplier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consignee_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shipper_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tankage_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sch_start_date] [datetime] NOT NULL,
[sch_stop_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[shipment_id] [int] NULL,
[parcel_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_schedule_line_item] ON [dbo].[aud_ag_schedule_line_item] ([fdd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_schedule_line_item_idx1] ON [dbo].[aud_ag_schedule_line_item] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ag_schedule_line_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_schedule_line_item] TO [next_usr]
GO
