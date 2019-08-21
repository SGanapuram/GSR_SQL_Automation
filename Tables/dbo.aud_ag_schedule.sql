CREATE TABLE [dbo].[aud_ag_schedule]
(
[fd_oid] [int] NOT NULL,
[create_date_time] [datetime] NOT NULL,
[carrier_code] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[market_place] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pipeline_num] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[last_update_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[doc_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_schedule] ON [dbo].[aud_ag_schedule] ([fd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_schedule_idx1] ON [dbo].[aud_ag_schedule] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ag_schedule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_schedule] TO [next_usr]
GO
