CREATE TABLE [dbo].[aud_location_ext_info]
(
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[accountant_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scheduler_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trader_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[county_code] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[city_code] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dflt_mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[permit_holder_acct_num] [int] NULL,
[excise_warehouse_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bonded_warehouse_loc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[postal_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_legal_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_lsd_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[oper_govt_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[oper_legal_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_location_ext_info] ON [dbo].[aud_location_ext_info] ([loc_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_location_ext_info_idx1] ON [dbo].[aud_location_ext_info] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_location_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_location_ext_info] TO [next_usr]
GO
