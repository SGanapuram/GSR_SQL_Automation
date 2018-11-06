CREATE TABLE [dbo].[aud_ag_truck_actual_details]
(
[fdd_id] [int] NOT NULL,
[lease_num] [int] NULL,
[lease_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_date] [datetime] NULL,
[gross_volume] [decimal] (20, 8) NULL,
[net_volume] [decimal] (20, 8) NULL,
[bill_of_lading_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[company_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[destination_facility] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[vehicle_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[railcar_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[product_code] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[opening_reading] [decimal] (20, 8) NULL,
[closing_reading] [decimal] (20, 8) NULL,
[operator_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tax] [decimal] (20, 8) NULL,
[net_value] [decimal] (20, 8) NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_num] [smallint] NULL,
[generic_col1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col7] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col8] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col9] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_col10] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[feed_source_type] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[gross_volume_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[net_volume_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_tank] [int] NULL,
[load_meter_open] [numeric] (20, 8) NULL,
[load_meter_open2] [numeric] (20, 8) NULL,
[load_meter_close] [numeric] (20, 8) NULL,
[load_meter_close2] [numeric] (20, 8) NULL,
[load_meter_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_temp] [numeric] (20, 8) NULL,
[load_temp_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_tank] [int] NULL,
[discharge_meter_open] [numeric] (20, 8) NULL,
[discharge_meter_open2] [numeric] (20, 8) NULL,
[discharge_meter_close] [numeric] (20, 8) NULL,
[discharge_meter_close2] [numeric] (20, 8) NULL,
[discharge_meter_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_temp] [numeric] (20, 8) NULL,
[discharge_temp_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[offload_railcar] [numeric] (20, 8) NULL,
[rins_expected] [numeric] (20, 8) NULL,
[rins_received] [numeric] (20, 8) NULL,
[govt_certificate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mileage] [numeric] (20, 8) NULL,
[system_well_id] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_time] [datetime] NULL,
[tank_size] [numeric] (20, 8) NULL,
[load_meter_open_qty] [numeric] (20, 8) NULL,
[load_meter_close_qty] [numeric] (20, 8) NULL,
[quantity_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_gross_vol] [numeric] (20, 8) NULL,
[meter_open_time] [datetime] NULL,
[meter_close_time] [datetime] NULL,
[temp_factor] [numeric] (20, 8) NULL,
[meter_factor] [numeric] (20, 8) NULL,
[rejected_load] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[action_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value6] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value7] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value8] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value9] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value11] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value12] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value13] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value14] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_value15] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_truck_actual_details] ON [dbo].[aud_ag_truck_actual_details] ([fdd_id], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_truck_actual_details_idx1] ON [dbo].[aud_ag_truck_actual_details] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_truck_actual_details] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_truck_actual_details] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_truck_actual_details] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_truck_actual_details] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_truck_actual_details] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_truck_actual_details', NULL, NULL
GO
