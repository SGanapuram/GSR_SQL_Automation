CREATE TABLE [dbo].[qp_period]
(
[oid] [int] NOT NULL,
[qp_option_oid] [int] NULL,
[time_unit] [int] NULL,
[time_frame] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_qp_period_time_frame] DEFAULT ('D'),
[app_cond] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_qp_period_app_cond] DEFAULT ('OF'),
[trigger_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[default_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[avg_time_unit] [int] NULL,
[avg_time_frame] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_qp_period_avg_time_frame] DEFAULT ('D'),
[trigger_event] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event_desc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [chk_qp_period_app_cond] CHECK (([app_cond]='BEFORE' OR [app_cond]='AFTER' OR [app_cond]='OF'))
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [chk_qp_period_avg_time_frame] CHECK (([avg_time_frame]='M' OR [avg_time_frame]='W' OR [avg_time_frame]='D'))
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [chk_qp_period_time_frame] CHECK (([time_frame]='M' OR [time_frame]='W' OR [time_frame]='D'))
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [qp_period_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[qp_period] ADD CONSTRAINT [qp_period_fk1] FOREIGN KEY ([qp_option_oid]) REFERENCES [dbo].[qp_option] ([oid])
GO
GRANT DELETE ON  [dbo].[qp_period] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[qp_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[qp_period] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[qp_period] TO [next_usr]
GO
