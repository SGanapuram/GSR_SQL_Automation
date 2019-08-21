CREATE TABLE [dbo].[als_run_touch_archive]
(
[als_module_group_id] [int] NOT NULL,
[operation] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NULL,
[sequence] [numeric] (32, 0) NOT NULL,
[touch_key] [numeric] (32, 0) NOT NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [df_als_run_touch_archive_archived_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[als_run_touch_archive] ADD CONSTRAINT [als_run_touch_archive_pk] PRIMARY KEY CLUSTERED  ([als_module_group_id], [touch_key], [archived_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [als_run_touch_archive_idx1] ON [dbo].[als_run_touch_archive] ([archived_date], [als_module_group_id], [sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[als_run_touch_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[als_run_touch_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[als_run_touch_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[als_run_touch_archive] TO [next_usr]
GO
