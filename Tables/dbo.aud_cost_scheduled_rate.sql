CREATE TABLE [dbo].[aud_cost_scheduled_rate]
(
[cost_num] [int] NOT NULL,
[seq_num] [smallint] NOT NULL,
[scheduled_scale] [float] NOT NULL,
[scheduled_rate] [float] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_scheduled_rate] ON [dbo].[aud_cost_scheduled_rate] ([cost_num], [seq_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_scheduled_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_scheduled_rate] TO [next_usr]
GO
