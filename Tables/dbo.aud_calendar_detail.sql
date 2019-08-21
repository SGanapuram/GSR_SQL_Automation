CREATE TABLE [dbo].[aud_calendar_detail]
(
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_date] [datetime] NOT NULL,
[calendar_date_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_date_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_calendar_detail] ON [dbo].[aud_calendar_detail] ([calendar_code], [calendar_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_calendar_detail_idx1] ON [dbo].[aud_calendar_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_calendar_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_calendar_detail] TO [next_usr]
GO
