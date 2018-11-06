CREATE TABLE [dbo].[aud_calendar]
(
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[calendar_date_mask] [char] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[calendar_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_calendar] ON [dbo].[aud_calendar] ([calendar_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_calendar_idx1] ON [dbo].[aud_calendar] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_calendar] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_calendar] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_calendar] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_calendar] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_calendar] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_calendar', NULL, NULL
GO
