CREATE TABLE [dbo].[aud_var_run]
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
[var_method] [smallint] NULL,
[operation] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[date_op] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_var_run] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_var_run] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_var_run] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_var_run] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_var_run] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_var_run', NULL, NULL
GO
