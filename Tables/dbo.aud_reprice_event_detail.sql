CREATE TABLE [dbo].[aud_reprice_event_detail]
(
[reprice_event_oid] [int] NOT NULL,
[reprice_event_detail_num] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[key1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_reprice_event_detail] ON [dbo].[aud_reprice_event_detail] ([reprice_event_oid], [reprice_event_detail_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_reprice_event_detail_idx1] ON [dbo].[aud_reprice_event_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_reprice_event_detail] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_reprice_event_detail] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_reprice_event_detail] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_reprice_event_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_reprice_event_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_reprice_event_detail', NULL, NULL
GO
