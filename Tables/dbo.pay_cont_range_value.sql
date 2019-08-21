CREATE TABLE [dbo].[pay_cont_range_value]
(
[oid] [int] NOT NULL,
[cp_formula_oid] [int] NULL,
[price_rule_oid] [int] NULL,
[pay_range_def_oid1] [int] NULL,
[pay_range_def_oid2] [int] NULL,
[percentage] [float] NULL,
[deduction] [float] NULL,
[application] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_cont_range_value] ADD CONSTRAINT [pay_cont_range_value_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_cont_range_value] ADD CONSTRAINT [pay_cont_range_value_fk1] FOREIGN KEY ([cp_formula_oid]) REFERENCES [dbo].[contract_pricing_formula] ([oid])
GO
ALTER TABLE [dbo].[pay_cont_range_value] ADD CONSTRAINT [pay_cont_range_value_fk2] FOREIGN KEY ([price_rule_oid]) REFERENCES [dbo].[pricing_rule] ([oid])
GO
ALTER TABLE [dbo].[pay_cont_range_value] ADD CONSTRAINT [pay_cont_range_value_fk3] FOREIGN KEY ([pay_range_def_oid1]) REFERENCES [dbo].[pay_cont_range_def] ([oid])
GO
GRANT DELETE ON  [dbo].[pay_cont_range_value] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pay_cont_range_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pay_cont_range_value] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pay_cont_range_value] TO [next_usr]
GO
