CREATE TABLE [dbo].[aud_ag_btt_schedule_updt]
(
[fd_oid] [int] NOT NULL,
[sender] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[transmittal_type] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_id] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[line_item_cnt] [int] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_schedule_updt] ON [dbo].[aud_ag_btt_schedule_updt] ([fd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_schedule_updt_idx1] ON [dbo].[aud_ag_btt_schedule_updt] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_ag_btt_schedule_updt] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_schedule_updt] TO [next_usr]
GO
