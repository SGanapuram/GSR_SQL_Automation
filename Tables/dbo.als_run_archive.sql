CREATE TABLE [dbo].[als_run_archive]
(
[sequence] [numeric] (32, 0) NOT NULL,
[als_module_group_id] [int] NOT NULL,
[instance_num] [smallint] NULL,
[als_run_status_id] [smallint] NOT NULL,
[start_time] [datetime] NOT NULL,
[end_time] [datetime] NULL,
[trans_id] [int] NOT NULL,
[creation_time] [datetime] NULL,
[archived_date] [datetime] NOT NULL CONSTRAINT [DF__als_run_a__archi__42E1EEFE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[als_run_archive] ADD CONSTRAINT [als_run_archive_pk] PRIMARY KEY CLUSTERED  ([sequence], [als_module_group_id], [archived_date]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [als_run_archive_idx1] ON [dbo].[als_run_archive] ([archived_date], [als_run_status_id], [sequence], [als_module_group_id]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[als_run_archive] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[als_run_archive] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[als_run_archive] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[als_run_archive] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'als_run_archive', NULL, NULL
GO
