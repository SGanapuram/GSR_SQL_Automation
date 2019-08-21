CREATE TABLE [dbo].[TI_feed_schedule]
(
[oid] [int] NOT NULL,
[feed_oid] [int] NOT NULL,
[day_of_week] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[day_of_month] [varchar] (96) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[start_time] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[end_time] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[frequency] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_schedule] ADD CONSTRAINT [TI_feed_schedule_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_schedule] ADD CONSTRAINT [TI_feed_schedule_fk1] FOREIGN KEY ([feed_oid]) REFERENCES [dbo].[TI_feed_definition] ([oid])
GO
GRANT DELETE ON  [dbo].[TI_feed_schedule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_feed_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_feed_schedule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_feed_schedule] TO [next_usr]
GO
