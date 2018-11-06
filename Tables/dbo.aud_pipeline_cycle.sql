CREATE TABLE [dbo].[aud_pipeline_cycle]
(
[pipeline_cycle_num] [int] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[timing_cycle_num] [smallint] NOT NULL,
[split_cycle_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[timing_cycle_mth] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cycle_start_date] [datetime] NOT NULL,
[cycle_end_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pipeline_cycle] ON [dbo].[aud_pipeline_cycle] ([pipeline_cycle_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pipeline_cycle_idx1] ON [dbo].[aud_pipeline_cycle] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_pipeline_cycle] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_pipeline_cycle] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_pipeline_cycle] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_pipeline_cycle] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pipeline_cycle] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_pipeline_cycle', NULL, NULL
GO
