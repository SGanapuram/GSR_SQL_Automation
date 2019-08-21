CREATE TABLE [dbo].[reprice_event_detail]
(
[reprice_event_oid] [int] NOT NULL,
[reprice_event_detail_num] [smallint] NOT NULL,
[entity_id] [int] NOT NULL,
[key1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[reprice_event_detail] ADD CONSTRAINT [reprice_event_detail_pk] PRIMARY KEY CLUSTERED  ([reprice_event_oid], [reprice_event_detail_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[reprice_event_detail] TO [next_usr]
GO
