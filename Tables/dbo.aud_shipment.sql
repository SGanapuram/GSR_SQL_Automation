CREATE TABLE [dbo].[aud_shipment]
(
[oid] [int] NOT NULL,
[status] [tinyint] NOT NULL,
[reference] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[primary_shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[capacity] [numeric] (20, 8) NULL,
[capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_qty] [numeric] (20, 8) NULL,
[ship_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[end_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[transport_owner_id] [int] NULL,
[transport_operator_id] [int] NULL,
[pipeline_cycle_num] [int] NULL,
[freight_rate] [numeric] (20, 8) NULL,
[freight_rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[freight_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[freight_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contract_num] [int] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[last_update_by_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_update_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[transport_reference] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[load_facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_tank_num] [int] NULL,
[dest_facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dest_tank_num] [int] NULL,
[contract_order_num] [int] NULL,
[manual_transport_parcels] [bit] NOT NULL CONSTRAINT [df_aud_shipment_manual_transport_parcels] DEFAULT ((1)),
[feed_interface] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[balance_qty] [numeric] (20, 8) NULL,
[sap_shipment_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_transfer_date] [datetime] NULL,
[shipment_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_bal] [numeric] (20, 8) NULL,
[ship_bal_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment] ON [dbo].[aud_shipment] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_shipment_idx1] ON [dbo].[aud_shipment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_shipment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_shipment] TO [next_usr]
GO
