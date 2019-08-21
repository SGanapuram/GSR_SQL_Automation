CREATE TABLE [dbo].[aud_strategy_execution_detail]
(
[strategy_id] [int] NOT NULL,
[strat_detail_num] [smallint] NOT NULL,
[exec_id] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_strategy_execution_detail] ON [dbo].[aud_strategy_execution_detail] ([strategy_id], [strat_detail_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_strategy_execution_detail_idx1] ON [dbo].[aud_strategy_execution_detail] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_strategy_execution_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_strategy_execution_detail] TO [next_usr]
GO
