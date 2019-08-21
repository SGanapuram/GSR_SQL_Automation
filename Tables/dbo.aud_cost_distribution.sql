CREATE TABLE [dbo].[aud_cost_distribution]
(
[cost_num] [int] NOT NULL,
[pos_num] [int] NOT NULL,
[real_port_num] [int] NOT NULL,
[closed_pl_group_num] [int] NULL,
[pl_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_amt] [float] NULL,
[vouched_amt] [float] NULL,
[total_amt] [float] NULL,
[cost_qty] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_distribution] ON [dbo].[aud_cost_distribution] ([cost_num], [pos_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_distribution_idx1] ON [dbo].[aud_cost_distribution] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_distribution] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_distribution] TO [next_usr]
GO
