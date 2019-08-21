CREATE TABLE [dbo].[parcel]
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
[bookco_bank_acct_num] [int] NULL,
[real_port_num] [int] NULL,
[int_value] [int] NULL,
[float_value] [float] NULL,
[string_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[date_sent_to_al] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [parcel_idx2] ON [dbo].[parcel] ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [parcel_idx1] ON [dbo].[parcel] ([shipment_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [parcel_idx3] ON [dbo].[parcel] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk1] FOREIGN KEY ([status]) REFERENCES [dbo].[parcel_status] ([oid])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk10] FOREIGN KEY ([nomin_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk12] FOREIGN KEY ([real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk2] FOREIGN KEY ([sch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk3] FOREIGN KEY ([location_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk4] FOREIGN KEY ([facility_code]) REFERENCES [dbo].[facility] ([facility_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk6] FOREIGN KEY ([product_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk7] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk8] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[parcel] ADD CONSTRAINT [parcel_fk9] FOREIGN KEY ([last_update_by_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[parcel] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[parcel] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[parcel] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[parcel] TO [next_usr]
GO
