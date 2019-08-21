CREATE TABLE [dbo].[TI_feed_definition]
(
[oid] [int] NOT NULL,
[feed_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[etl_timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TI_feed_definition] ADD CONSTRAINT [TI_feed_definition_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TI_feed_definition] TO [admin_group]
GO
GRANT INSERT ON  [dbo].[TI_feed_definition] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[TI_feed_definition] TO [admin_group]
GO
GRANT UPDATE ON  [dbo].[TI_feed_definition] TO [admin_group]
GO
GRANT DELETE ON  [dbo].[TI_feed_definition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[TI_feed_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[TI_feed_definition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[TI_feed_definition] TO [next_usr]
GO
