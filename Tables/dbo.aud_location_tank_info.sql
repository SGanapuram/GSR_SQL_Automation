CREATE TABLE [dbo].[aud_location_tank_info]
(
[tank_num] [int] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[long_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[excise_warehouse_loc_ind] [bit] NOT NULL,
[bonded_warehouse_loc_ind] [bit] NOT NULL,
[excise_info_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[legal_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[battery_govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_capacity] [decimal] (20, 8) NULL,
[tank_capacity_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[location_tank_info_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_aud_location_tank_info_location_tank_info_type] DEFAULT ('T'),
[confirmation_status] [bit] NOT NULL CONSTRAINT [df_aud_location_tank_info_confirmation_status] DEFAULT ((0)),
[first_purchaser_ind] [bit] NOT NULL CONSTRAINT [df_aud_location_tank_info_first_purchaser_ind] DEFAULT ((0)),
[well_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[api_well_num] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[meter_num] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[address_line1] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[address_line2] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[city_code] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[county_code] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[latitude] [numeric] (9, 6) NULL,
[longitude] [numeric] (9, 6) NULL,
[survey_address] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[field_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[geologic_formation] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[operator_num] [int] NULL,
[owner_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aud_location_tank_info] ADD CONSTRAINT [chk_aud_location_tank_info_location_tank_info_type] CHECK (([location_tank_info_type]='T' OR [location_tank_info_type]='L'))
GO
CREATE NONCLUSTERED INDEX [aud_location_tank_info_idx1] ON [dbo].[aud_location_tank_info] ([tank_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_location_tank_info_idx2] ON [dbo].[aud_location_tank_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_location_tank_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_location_tank_info] TO [next_usr]
GO
