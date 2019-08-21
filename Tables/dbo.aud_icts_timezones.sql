CREATE TABLE [dbo].[aud_icts_timezones]
(
[oid] [int] NULL,
[tz_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tz_utc_offset_hr] [int] NULL,
[tz_utc_offset_mm] [int] NULL,
[trans_id] [int] NULL,
[resp_trans_id] [int] NULL,
[tz_abbvr] [char] (5) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_timezones] ON [dbo].[aud_icts_timezones] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_icts_timezones_idx1] ON [dbo].[aud_icts_timezones] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_icts_timezones] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_icts_timezones] TO [next_usr]
GO
