CREATE TABLE [dbo].[aud_reprice_event]
(
[reprice_event_oid] [int] NOT NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_trans_id] [int] NOT NULL,
[event_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_reprice_event] ON [dbo].[aud_reprice_event] ([reprice_event_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_reprice_event_idx1] ON [dbo].[aud_reprice_event] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_reprice_event] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_reprice_event] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_reprice_event] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_reprice_event] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_reprice_event] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_reprice_event', NULL, NULL
GO
