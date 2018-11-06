CREATE TABLE [dbo].[aud_event]
(
[event_num] [int] NULL,
[event_time] [datetime] NULL,
[event_owner] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_asof_date] [datetime] NULL,
[event_owner_key1] [int] NULL,
[event_owner_key2] [int] NULL,
[event_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_controller] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_event_idx1] ON [dbo].[aud_event] ([event_description], [event_asof_date], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_event] ON [dbo].[aud_event] ([event_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_event_idx2] ON [dbo].[aud_event] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_event] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_event] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_event] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_event] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_event] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_event', NULL, NULL
GO
