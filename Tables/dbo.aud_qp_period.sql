CREATE TABLE [dbo].[aud_qp_period]
(
[oid] [int] NOT NULL,
[qp_option_oid] [int] NULL,
[time_unit] [int] NULL,
[time_frame] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[app_cond] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[default_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[avg_time_unit] [int] NULL,
[avg_time_frame] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_event_desc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qp_period] ON [dbo].[aud_qp_period] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qp_period_idx1] ON [dbo].[aud_qp_period] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_qp_period] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_qp_period] TO [next_usr]
GO
