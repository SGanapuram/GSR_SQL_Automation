CREATE TABLE [dbo].[job_schedule]
(
[job_schedule_num] [int] NOT NULL,
[job_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[job_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_job_schedule_job_status] DEFAULT ('A'),
[recur_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_job_schedule_recur_ind] DEFAULT ('N'),
[trigger_event_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event_status_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[drop_dead_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[job_schedule] ADD CONSTRAINT [chk_job_schedule_job_status] CHECK (([job_status]='X' OR [job_status]='C' OR [job_status]='A'))
GO
ALTER TABLE [dbo].[job_schedule] ADD CONSTRAINT [chk_job_schedule_recur_ind] CHECK (([recur_ind]='N' OR [recur_ind]='Y'))
GO
ALTER TABLE [dbo].[job_schedule] ADD CONSTRAINT [job_schedule_pk] PRIMARY KEY CLUSTERED  ([job_schedule_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[job_schedule] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[job_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[job_schedule] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[job_schedule] TO [next_usr]
GO
