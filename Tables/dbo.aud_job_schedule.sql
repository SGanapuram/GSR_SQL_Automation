CREATE TABLE [dbo].[aud_job_schedule]
(
[job_schedule_num] [int] NOT NULL,
[job_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[job_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[recur_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trigger_event_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event_status_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[drop_dead_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_job_schedule] ON [dbo].[aud_job_schedule] ([job_schedule_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_job_schedule_idx1] ON [dbo].[aud_job_schedule] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_job_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_job_schedule] TO [next_usr]
GO
