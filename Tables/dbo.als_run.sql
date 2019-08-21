CREATE TABLE [dbo].[als_run]
(
[sequence] [numeric] (32, 0) NOT NULL,
[als_module_group_id] [int] NOT NULL,
[instance_num] [smallint] NULL,
[als_run_status_id] [smallint] NOT NULL CONSTRAINT [df_als_run_als_run_status_id] DEFAULT ((0)),
[start_time] [datetime] NOT NULL CONSTRAINT [df_als_run_start_time] DEFAULT (getdate()),
[end_time] [datetime] NULL,
[trans_id] [int] NOT NULL,
[creation_time] [datetime] NULL CONSTRAINT [df_als_run_creation_time] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[als_run] ADD CONSTRAINT [als_run_pk] PRIMARY KEY CLUSTERED  ([sequence], [als_module_group_id]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [als_run_idx1] ON [dbo].[als_run] ([als_module_group_id], [als_run_status_id], [sequence], [instance_num]) WITH (ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[als_run] ADD CONSTRAINT [als_run_fk1] FOREIGN KEY ([sequence]) REFERENCES [dbo].[icts_transaction] ([sequence])
GO
ALTER TABLE [dbo].[als_run] ADD CONSTRAINT [als_run_fk2] FOREIGN KEY ([als_module_group_id]) REFERENCES [dbo].[server_config] ([als_module_group_id])
GO
ALTER TABLE [dbo].[als_run] ADD CONSTRAINT [als_run_fk3] FOREIGN KEY ([als_run_status_id]) REFERENCES [dbo].[als_run_status] ([als_run_status_id])
GO
GRANT DELETE ON  [dbo].[als_run] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[als_run] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[als_run] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[als_run] TO [next_usr]
GO
