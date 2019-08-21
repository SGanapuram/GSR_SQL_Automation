CREATE TABLE [dbo].[TI_TSW_schedule]
(
[oid] [int] NOT NULL,
[inbound_data_oid] [int] NOT NULL,
[transport_system] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transport_system_carrier] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_header_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_quantity] [numeric] (18, 3) NULL,
[discharge_quantity] [numeric] (18, 3) NULL,
[nomin_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shipping_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[header_delete_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_key] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_key_item] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[schedule_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_item_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[schedule_date] [datetime] NULL,
[location_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[planning_location_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_partner_plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_partner_storage_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[demand_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduled_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduled_quantity] [numeric] (18, 3) NULL,
[scheduled_uom] [char] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_ref_doc_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ref_doc_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_ref_doc_item] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_item_partial_compl_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_posted_quantity] [numeric] (18, 3) NULL,
[actual_posted_quantity_uom] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delete_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[change_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[planning_month] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_1] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_1_qty] [numeric] (18, 3) NULL,
[comp_material_2] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_2_qty] [numeric] (18, 3) NULL,
[comp_material_3] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_3_qty] [numeric] (18, 3) NULL,
[comp_material_4] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comp_material_4_qty] [numeric] (18, 3) NULL,
[sap_schedule_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_demand_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_location_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_schedule_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_demand_material] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pw_location_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[etl_timestamp] [datetime] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[in_transit_plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_TSW_schedule] ADD CONSTRAINT [TI_TSW_schedule_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_TSW_schedule] ADD CONSTRAINT [TI_TSW_schedule_fk1] FOREIGN KEY ([inbound_data_oid]) REFERENCES [dbo].[TI_inbound_data_xml] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_TSW_schedule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_TSW_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_TSW_schedule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_TSW_schedule] TO [next_usr]
GO
