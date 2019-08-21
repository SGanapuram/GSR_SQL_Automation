CREATE TABLE [dbo].[strategy_execution_detail]
(
[strategy_id] [int] NOT NULL,
[strat_detail_num] [smallint] NOT NULL,
[exec_id] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[strategy_execution_detail] ADD CONSTRAINT [strategy_execution_detail_pk] PRIMARY KEY CLUSTERED  ([strategy_id], [strat_detail_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[strategy_execution_detail] ADD CONSTRAINT [strategy_execution_detail_fk1] FOREIGN KEY ([strategy_id]) REFERENCES [dbo].[strategy_execution] ([oid])
GO
ALTER TABLE [dbo].[strategy_execution_detail] ADD CONSTRAINT [strategy_execution_detail_fk2] FOREIGN KEY ([exec_id]) REFERENCES [dbo].[contract_execution] ([oid])
GO
GRANT DELETE ON  [dbo].[strategy_execution_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[strategy_execution_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[strategy_execution_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[strategy_execution_detail] TO [next_usr]
GO
