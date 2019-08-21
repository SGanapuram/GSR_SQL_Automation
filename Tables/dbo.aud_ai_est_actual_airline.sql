CREATE TABLE [dbo].[aud_ai_est_actual_airline]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[auth_id] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[aircraft_num] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flight_num] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[before_fuel_qty] [float] NULL,
[equip_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flight_orig_date] [datetime] NULL,
[flight_region] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[flight_off_date] [datetime] NULL,
[vendor_auth_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sales_type] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[reg_nbr] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rsn_code] [char] (6) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[orig_trans_date] [datetime] NULL,
[trans_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ai_est_actual_airlin_idx1] ON [dbo].[aud_ai_est_actual_airline] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ai_est_actual_airline] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ai_est_actual_airline] TO [next_usr]
GO
