CREATE TABLE [dbo].[aud_ai_est_actual_interface]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [int] NOT NULL,
[ai_est_actual_num] [int] NOT NULL,
[feed_def_oid] [int] NULL,
[record_id] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[record_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[record_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[carrier] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[truck_or_rail_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_tank] [int] NULL,
[load_meter_open] [numeric] (20, 8) NULL,
[load_meter_open2] [numeric] (20, 8) NULL,
[load_meter_close] [numeric] (20, 8) NULL,
[load_meter_close2] [numeric] (20, 8) NULL,
[load_meter_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_temp] [numeric] (20, 8) NULL,
[load_temp_uom] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_tank] [int] NULL,
[discharge_meter_open] [numeric] (20, 8) NULL,
[discharge_meter_open2] [numeric] (20, 8) NULL,
[discharge_meter_close] [numeric] (20, 8) NULL,
[discharge_meter_close2] [numeric] (20, 8) NULL,
[discharge_meter_uom] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[discharge_temp] [numeric] (20, 8) NULL,
[discharge_temp_uom] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[offload_railcar] [numeric] (20, 8) NULL,
[rins_expected] [numeric] (20, 8) NULL,
[rins_received] [numeric] (20, 8) NULL,
[govt_certificate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mileage] [numeric] (20, 8) NULL,
[generic_column1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column6] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column7] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column8] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column9] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[generic_column10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[system_well_id] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_time] [datetime] NULL,
[tank_size] [numeric] (20, 8) NULL,
[load_meter_open_qty] [numeric] (20, 8) NULL,
[load_meter_close_qty] [numeric] (20, 8) NULL,
[quantity_uom] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[obs_gravity] [numeric] (20, 8) NULL,
[obs_bsw] [numeric] (20, 8) NULL,
[obs_temp] [numeric] (20, 8) NULL,
[ticket_gross_vol] [numeric] (20, 8) NULL,
[meter_open_time] [datetime] NULL,
[meter_close_time] [datetime] NULL,
[temp_factor] [numeric] (20, 8) NULL,
[meter_factor] [numeric] (20, 8) NULL,
[rejected_load] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ai_est_actual_interface] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_interface] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ai_est_actual_interface] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ai_est_actual_interface] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_interface] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ai_est_actual_interface', NULL, NULL
GO