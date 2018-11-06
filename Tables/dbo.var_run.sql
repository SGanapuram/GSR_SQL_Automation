CREATE TABLE [dbo].[var_run]
(
[oid] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[run_date] [datetime] NOT NULL,
[execute_date] [datetime] NOT NULL,
[no_of_iterations] [int] NULL,
[horizon] [int] NULL,
[min_obs_date_vol] [datetime] NULL,
[max_obs_date_vol] [datetime] NULL,
[port_num_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[min_obs_date_corr] [datetime] NULL,
[max_obs_date_corr] [datetime] NULL,
[min_obs_date_his] [datetime] NULL,
[max_obs_date_his] [datetime] NULL,
[parameter_est_method] [smallint] NULL,
[var_method] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [CK__var_run__paramet__38D00B8D] CHECK (([parameter_est_method]=NULL OR [parameter_est_method]=(2) OR [parameter_est_method]=(1)))
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [CK__var_run__var_met__39C42FC6] CHECK (([var_method]=NULL OR [var_method]=(2) OR [var_method]=(1)))
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [var_run_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[var_run] ADD CONSTRAINT [var_run_fk1] FOREIGN KEY ([user_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[var_run] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[var_run] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[var_run] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[var_run] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'var_run', NULL, NULL
GO
