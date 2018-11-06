CREATE TABLE [dbo].[aud_parcel]
(
[oid] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[associative_state] [tinyint] NOT NULL,
[status] [tinyint] NOT NULL,
[reference] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_qty] [numeric] (20, 8) NULL,
[sch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_code] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[grade] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[quality] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[estimated_date] [datetime] NULL,
[sch_from_date] [datetime] NULL,
[sch_to_date] [datetime] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[last_update_by_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_update_date] [datetime] NULL,
[forecast_num] [int] NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[inv_num] [int] NULL,
[shipment_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[nomin_qty] [numeric] (20, 8) NULL,
[nomin_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[t4_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[t4_consignee] [int] NULL,
[t4_tankage] [int] NULL,
[gn_taric_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tariff_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excise_status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transmitall_type] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inspector] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[latest_feed_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[send_to_sap] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bookco_bank_acct_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parcel] ON [dbo].[aud_parcel] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_parcel_idx1] ON [dbo].[aud_parcel] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_parcel] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_parcel] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_parcel] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_parcel] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_parcel] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_parcel', NULL, NULL
GO
