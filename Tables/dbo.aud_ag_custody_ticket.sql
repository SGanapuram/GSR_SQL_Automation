CREATE TABLE [dbo].[aud_ag_custody_ticket]
(
[fdd_oid] [int] NOT NULL,
[batch_number] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_id] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[location_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[supplier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[consignee_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shipper_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tankage_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bol_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[market_place] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ticket_datetime] [datetime] NOT NULL,
[timezone] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_number] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_start_date] [datetime] NOT NULL,
[transfer_stop_date] [datetime] NOT NULL,
[transport_method_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[net_qty] [numeric] (20, 8) NOT NULL,
[net_qty_uom] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gross_qty] [numeric] (20, 8) NOT NULL,
[gross_qty_uom] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pipeline_num] [int] NULL,
[line_item_tank_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[doc_id] [int] NOT NULL,
[trans_purpose_ind] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transport_event] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[observed_temp] [numeric] (20, 8) NULL,
[observed_temp_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[average_temp] [numeric] (20, 8) NULL,
[average_temp_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[average_pressure] [numeric] (20, 8) NULL,
[average_pressure_uom] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[apl_gravity] [numeric] (20, 8) NULL,
[corrected_gravity] [numeric] (20, 8) NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_custody_ticket] ON [dbo].[aud_ag_custody_ticket] ([fdd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_custody_ticket_idx1] ON [dbo].[aud_ag_custody_ticket] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ag_custody_ticket] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_custody_ticket] TO [next_usr]
GO
