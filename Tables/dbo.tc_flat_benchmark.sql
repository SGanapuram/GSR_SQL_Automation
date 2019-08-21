CREATE TABLE [dbo].[tc_flat_benchmark]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[flat_amt] [float] NULL,
[flat_percentage] [float] NULL,
[app_to_flat] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[benchmark_detail_oid] [int] NULL,
[benchmark_value] [float] NULL,
[benchmark_percentage] [float] NULL,
[app_to_benchmark] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tc_value] [float] NULL,
[trans_id] [int] NOT NULL,
[from_value] [float] NULL,
[to_value] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tc_flat_benchmark] ADD CONSTRAINT [tc_flat_benchmark_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tc_flat_benchmark] ADD CONSTRAINT [tc_flat_benchmark_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[tc_flat_benchmark] ADD CONSTRAINT [tc_flat_benchmark_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
ALTER TABLE [dbo].[tc_flat_benchmark] ADD CONSTRAINT [tc_flat_benchmark_fk3] FOREIGN KEY ([benchmark_detail_oid]) REFERENCES [dbo].[benchmark_detail] ([oid])
GO
GRANT DELETE ON  [dbo].[tc_flat_benchmark] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[tc_flat_benchmark] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[tc_flat_benchmark] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[tc_flat_benchmark] TO [next_usr]
GO
