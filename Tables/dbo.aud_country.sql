CREATE TABLE [dbo].[aud_country]
(
[country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[no_bus_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_num] [smallint] NOT NULL,
[country_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[int_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ext_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[country_limit_amt] [float] NOT NULL,
[country_limit_util_amt] [float] NULL,
[cmnt_num] [int] NULL,
[exposure_priority_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[iso_country_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_country] ON [dbo].[aud_country] ([country_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_country_idx1] ON [dbo].[aud_country] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_country] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_country] TO [next_usr]
GO
